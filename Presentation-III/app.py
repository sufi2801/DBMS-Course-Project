import os
from datetime import date, datetime, time
from decimal import Decimal

import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import streamlit as st

load_dotenv()

# ============================================================
# PAGE CONFIG
# ============================================================
st.set_page_config(
    page_title="Farm Management Dashboard",
    page_icon="🌾",
    layout="wide",
    initial_sidebar_state="expanded",
)

# ============================================================
# DATABASE
# ============================================================
def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME", "farm_management"),
    )


def run_select(sql, params=()):
    conn = get_connection()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(sql, params)
        return cur.fetchall()
    finally:
        cur.close()
        conn.close()


def run_action(sql, params=()):
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute(sql, params)
        conn.commit()
        return cur.rowcount, cur.lastrowid
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


# ============================================================
# SCHEMA INTROSPECTION
# The UI automatically covers every base table in the database.
# ============================================================
@st.cache_data(ttl=30)
def get_tables():
    rows = run_select("""
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_TYPE = 'BASE TABLE'
        ORDER BY TABLE_NAME
    """)
    return [r["TABLE_NAME"] for r in rows]


@st.cache_data(ttl=30)
def get_views():
    rows = run_select("""
        SELECT TABLE_NAME
        FROM information_schema.VIEWS
        WHERE TABLE_SCHEMA = DATABASE()
        ORDER BY TABLE_NAME
    """)
    return [r["TABLE_NAME"] for r in rows]


@st.cache_data(ttl=30)
def get_columns(table):
    return run_select("""
        SELECT
            COLUMN_NAME,
            DATA_TYPE,
            COLUMN_TYPE,
            IS_NULLABLE,
            COLUMN_DEFAULT,
            EXTRA,
            ORDINAL_POSITION
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = %s
        ORDER BY ORDINAL_POSITION
    """, (table,))


@st.cache_data(ttl=30)
def get_primary_keys(table):
    rows = run_select("""
        SELECT COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = %s
          AND CONSTRAINT_NAME = 'PRIMARY'
        ORDER BY ORDINAL_POSITION
    """, (table,))
    return [r["COLUMN_NAME"] for r in rows]


@st.cache_data(ttl=30)
def get_foreign_keys(table):
    return run_select("""
        SELECT
            COLUMN_NAME,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = %s
          AND REFERENCED_TABLE_NAME IS NOT NULL
        ORDER BY ORDINAL_POSITION
    """, (table,))


@st.cache_data(ttl=30)
def get_unique_columns(table):
    return run_select("""
        SELECT DISTINCT COLUMN_NAME
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = %s
          AND NON_UNIQUE = 0
          AND INDEX_NAME <> 'PRIMARY'
        ORDER BY COLUMN_NAME
    """, (table,))


def qident(name):
    return "`" + str(name).replace("`", "``") + "`"


def is_generated(col):
    extra = (col.get("EXTRA") or "").lower()
    return "generated" in extra


def is_auto_increment(col):
    return "auto_increment" in (col.get("EXTRA") or "").lower()


def is_temporal(dtype):
    return dtype in {"date", "datetime", "timestamp", "time"}


def format_value(value):
    if value is None:
        return "NULL"
    if isinstance(value, (date, datetime, time)):
        return value.isoformat(sep=" ") if isinstance(value, datetime) else value.isoformat()
    return str(value)


def row_label(row, pk_cols):
    if not pk_cols:
        return "Record"
    return " | ".join(f"{k}={format_value(row.get(k))}" for k in pk_cols)


def invalidate_schema_cache():
    get_tables.clear()
    get_views.clear()
    get_columns.clear()
    get_primary_keys.clear()
    get_foreign_keys.clear()
    get_unique_columns.clear()


# ============================================================
# FOREIGN KEY OPTIONS
# ============================================================
@st.cache_data(ttl=20)
def get_fk_options(ref_table, ref_column):
    rows = run_select(
        f"SELECT {qident(ref_column)} AS value FROM {qident(ref_table)} "
        f"ORDER BY {qident(ref_column)}"
    )
    return [r["value"] for r in rows]


def fk_widget(table, col, fk, key_prefix):
    options = get_fk_options(
        fk["REFERENCED_TABLE_NAME"],
        fk["REFERENCED_COLUMN_NAME"],
    )

    if not options:
        st.warning(
            f"No records exist in {fk['REFERENCED_TABLE_NAME']} "
            f"for {fk['REFERENCED_COLUMN_NAME']}. Create the parent record first."
        )
        return None

    labels = [format_value(v) for v in options]
    selected = st.selectbox(
        f"{col} → {fk['REFERENCED_TABLE_NAME']}.{fk['REFERENCED_COLUMN_NAME']}",
        labels,
        key=f"{key_prefix}_{table}_{col}",
    )
    return options[labels.index(selected)]


# ============================================================
# INPUT WIDGETS
# ============================================================
def value_widget(table, col, existing=None, mode="insert", fk=None):
    name = col["COLUMN_NAME"]
    dtype = col["DATA_TYPE"].lower()
    nullable = col["IS_NULLABLE"] == "YES"
    default = col.get("COLUMN_DEFAULT")

    if is_generated(col) or is_auto_increment(col):
        return None, False

    if fk:
        value = fk_widget(table, name, fk, f"{mode}_fk")
        return value, True

    if nullable:
        use_null = st.checkbox(
            f"Set {name} to NULL",
            value=False,
            key=f"{mode}_null_{table}_{name}",
        )
        if use_null:
            return None, True

    if dtype in {"int", "integer", "bigint", "smallint", "mediumint", "tinyint"}:
        current = int(existing) if existing is not None else 0
        return st.number_input(
            name,
            value=current,
            step=1,
            key=f"{mode}_{table}_{name}",
        ), True

    if dtype in {"decimal", "numeric", "float", "double", "real"}:
        current = float(existing) if existing is not None else 0.0
        return st.number_input(
            name,
            value=current,
            step=0.01,
            format="%.2f",
            key=f"{mode}_{table}_{name}",
        ), True

    if dtype == "date":
        current = existing if isinstance(existing, date) and not isinstance(existing, datetime) else date.today()
        return st.date_input(
            name,
            value=current,
            key=f"{mode}_{table}_{name}",
        ), True

    if dtype in {"datetime", "timestamp"}:
        current = existing if isinstance(existing, datetime) else datetime.now()
        d = st.date_input(f"{name} — date", value=current.date(), key=f"{mode}_d_{table}_{name}")
        t = st.time_input(f"{name} — time", value=current.time(), key=f"{mode}_t_{table}_{name}")
        return datetime.combine(d, t), True

    if dtype == "time":
        current = existing if isinstance(existing, time) else time(0, 0)
        return st.time_input(name, value=current, key=f"{mode}_{table}_{name}"), True

    if dtype == "enum":
        raw = col.get("COLUMN_TYPE", "")
        values = raw[5:-1].split(",") if raw.startswith("enum(") else []
        values = [v.strip().strip("'") for v in values]
        current = str(existing) if existing is not None else (values[0] if values else "")
        return st.selectbox(
            name,
            values,
            index=values.index(current) if current in values else 0,
            key=f"{mode}_{table}_{name}",
        ), True

    current = "" if existing is None else str(existing)
    return st.text_input(
        name,
        value=current,
        key=f"{mode}_{table}_{name}",
    ), True


def clean_value(value):
    if isinstance(value, date) and not isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, time):
        return value.isoformat()
    if isinstance(value, datetime):
        return value.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(value, Decimal):
        return float(value)
    return value


# ============================================================
# CRUD
# ============================================================
def insert_record(table, columns, fks):
    values = {}
    for col in columns:
        if is_generated(col) or is_auto_increment(col):
            continue
        fk = next((x for x in fks if x["COLUMN_NAME"] == col["COLUMN_NAME"]), None)
        value, include = value_widget(table, col, mode="insert", fk=fk)
        if include:
            values[col["COLUMN_NAME"]] = clean_value(value)

    if st.button(f"➕ Insert into {table}", type="primary", use_container_width=True):
        if not values:
            st.warning("No insertable fields were supplied.")
            return
        cols = list(values.keys())
        sql = (
            f"INSERT INTO {qident(table)} "
            f"({', '.join(qident(c) for c in cols)}) "
            f"VALUES ({', '.join(['%s'] * len(cols))})"
        )
        try:
            _, new_id = run_action(sql, tuple(values[c] for c in cols))
            st.success(f"{table} record inserted successfully. New ID: {new_id}")
            st.cache_data.clear()
        except Error as e:
            st.error(f"Insert failed: {e}")


def delete_record(table, rows, pk_cols):
    if not rows:
        st.info("No records available to delete.")
        return
    if not pk_cols:
        st.error("This table has no primary key; safe row deletion is disabled.")
        return

    labels = [row_label(r, pk_cols) for r in rows]
    selected = st.selectbox("Select record to delete", labels, key=f"delete_select_{table}")
    row = rows[labels.index(selected)]

    st.warning("Delete permanently removes the selected database record. Foreign-key rules may prevent deletion or cascade it.")

    if st.button(f"🗑️ Delete from {table}", type="primary", use_container_width=True):
        where = " AND ".join(f"{qident(k)} = %s" for k in pk_cols)
        params = tuple(row[k] for k in pk_cols)
        try:
            count, _ = run_action(f"DELETE FROM {qident(table)} WHERE {where}", params)
            if count:
                st.success("Record deleted successfully.")
                st.cache_data.clear()
                st.rerun()
            else:
                st.warning("No record was deleted.")
        except Error as e:
            st.error(f"Delete failed: {e}")


def update_record(table, rows, columns, pk_cols, fks):
    if not rows:
        st.info("No records available to update.")
        return
    if not pk_cols:
        st.error("This table has no primary key; safe row updates are disabled.")
        return

    labels = [row_label(r, pk_cols) for r in rows]
    selected = st.selectbox("Select record to update", labels, key=f"update_select_{table}")
    row = rows[labels.index(selected)]

    updates = {}
    st.caption("Edit the fields below. Primary-key, auto-increment, and generated columns are read-only.")

    editable = [c for c in columns if c["COLUMN_NAME"] not in pk_cols]
    for col in editable:
        if is_generated(col) or is_auto_increment(col):
            continue
        fk = next((x for x in fks if x["COLUMN_NAME"] == col["COLUMN_NAME"]), None)
        value, include = value_widget(
            table, col, existing=row.get(col["COLUMN_NAME"]), mode="update", fk=fk
        )
        if include:
            updates[col["COLUMN_NAME"]] = clean_value(value)

    if st.button(f"✏️ Update {table}", type="primary", use_container_width=True):
        if not updates:
            st.warning("No editable fields were supplied.")
            return

        set_clause = ", ".join(f"{qident(k)} = %s" for k in updates)
        where = " AND ".join(f"{qident(k)} = %s" for k in pk_cols)
        params = tuple(updates.values()) + tuple(row[k] for k in pk_cols)

        try:
            count, _ = run_action(
                f"UPDATE {qident(table)} SET {set_clause} WHERE {where}",
                params,
            )
            if count:
                st.success("Record updated successfully.")
                st.cache_data.clear()
                st.rerun()
            else:
                st.info("No database values changed.")
        except Error as e:
            st.error(f"Update failed: {e}")


# ============================================================
# ANALYTICS
# ============================================================
def analytics_page():
    st.header("📊 Farm Analytics")

    views = get_views()
    if "cropprofitability" in [v.lower() for v in views]:
        try:
            rows = run_select("SELECT * FROM cropprofitability ORDER BY plan_id")
            if rows:
                st.subheader("Crop Profitability")
                st.dataframe(rows, use_container_width=True, hide_index=True)
                st.download_button(
                    "Download profitability CSV",
                    data=__import__("pandas").DataFrame(rows).to_csv(index=False),
                    file_name="crop_profitability.csv",
                    mime="text/csv",
                )
            else:
                st.info("The profitability view currently has no rows.")
        except Error as e:
            st.error(f"Could not read cropprofitability: {e}")

    analytics = {
        "Input Costs by Crop": """
            SELECT c.crop_name, ROUND(SUM(i.unit_cost * a.quantity_used), 2) AS input_cost
            FROM Application a
            JOIN Input i ON a.input_id = i.input_id
            JOIN CropPlan cp ON a.plan_id = cp.plan_id
            JOIN Variety v ON cp.variety_id = v.variety_id
            JOIN Crop c ON v.crop_id = c.crop_id
            GROUP BY c.crop_name
            ORDER BY input_cost DESC
        """,
        "Yield Exceptions": """
            SELECT cp.plan_id, c.crop_name, cp.expected_yield_kg, h.actual_yield_kg
            FROM CropPlan cp
            JOIN Variety v ON cp.variety_id = v.variety_id
            JOIN Crop c ON v.crop_id = c.crop_id
            JOIN (
                SELECT plan_id, SUM(quantity_kg) AS actual_yield_kg
                FROM Harvest
                GROUP BY plan_id
            ) h ON cp.plan_id = h.plan_id
            WHERE h.actual_yield_kg <> cp.expected_yield_kg
            ORDER BY cp.plan_id
        """,
        "Revenue by Buyer": """
            SELECT b.buyer_name, ROUND(SUM(s.total_amount), 2) AS revenue
            FROM Sale s
            JOIN Buyer b ON s.buyer_id = b.buyer_id
            GROUP BY b.buyer_id, b.buyer_name
            ORDER BY revenue DESC
        """,
        "Remaining Harvest Stock": """
            SELECT h.harvest_id, c.crop_name,
                   h.quantity_kg - COALESCE(SUM(s.quantity_sold_kg), 0) AS remaining_kg
            FROM Harvest h
            JOIN CropPlan cp ON h.plan_id = cp.plan_id
            JOIN Variety v ON cp.variety_id = v.variety_id
            JOIN Crop c ON v.crop_id = c.crop_id
            LEFT JOIN Sale s ON h.harvest_id = s.harvest_id
            GROUP BY h.harvest_id, c.crop_name, h.quantity_kg
            ORDER BY h.harvest_id
        """,
    }

    for title, sql in analytics.items():
        with st.expander(title, expanded=False):
            try:
                rows = run_select(sql)
                st.dataframe(rows, use_container_width=True, hide_index=True)
            except Error as e:
                st.error(f"Query failed: {e}")


# ============================================================
# DASHBOARD
# ============================================================
def dashboard_page(tables):
    st.header("🌾 Farm Management Dashboard")
    st.caption("Live statistics from the MySQL database")

    preferred = [
        ("Farm", "🏡"),
        ("Field", "🌱"),
        ("Crop", "🌾"),
        ("CropPlan", "📋"),
        ("Harvest", "🚜"),
        ("Sale", "💰"),
    ]

    cols = st.columns(len(preferred))
    for col, (table, icon) in zip(cols, preferred):
        with col:
            if table in tables:
                try:
                    count = run_select(f"SELECT COUNT(*) AS n FROM {qident(table)}")[0]["n"]
                    st.metric(f"{icon} {table}", count)
                except Error:
                    st.metric(table, "—")

    st.divider()

    c1, c2 = st.columns(2)
    with c1:
        st.subheader("Database Tables")
        st.write(f"**{len(tables)} tables** available for full CRUD management.")
        st.dataframe(
            [{"Table": t} for t in tables],
            use_container_width=True,
            hide_index=True,
            height=300,
        )

    with c2:
        st.subheader("Database Views")
        views = get_views()
        if views:
            st.dataframe(
                [{"View": v} for v in views],
                use_container_width=True,
                hide_index=True,
            )
        else:
            st.info("No database views found.")


# ============================================================
# MAIN APP
# ============================================================
st.title("🌾 Crop Planning & Farm Input Management System")
st.caption("Complete MySQL Database Management Dashboard")

try:
    tables = get_tables()
    if not tables:
        st.error("No tables were found in the configured database.")
        st.stop()
except Error as e:
    st.error(f"Database connection error: {e}")
    st.stop()

# Sidebar
st.sidebar.title("🌾 Farm Management")
st.sidebar.caption(f"MySQL: {os.getenv('DB_NAME', 'farm_management')}")

sections = {
    "🏠 Dashboard": ["Dashboard"],
    "📋 Data Management": tables,
    "📊 Analytics": ["Analytics"],
}

section = st.sidebar.selectbox("Section", list(sections.keys()))

if section == "🏠 Dashboard":
    dashboard_page(tables)

elif section == "📊 Analytics":
    analytics_page()

else:
    table = st.sidebar.selectbox("Select Table", tables)
    action = st.sidebar.radio(
        "Operation",
        ["View", "Insert", "Update", "Delete"],
        horizontal=False,
    )

    columns = get_columns(table)
    fks = get_foreign_keys(table)
    pk_cols = get_primary_keys(table)

    st.header(f"🗃️ {table}")
    st.caption(
        f"Primary key: {', '.join(pk_cols) if pk_cols else 'none'}"
        f"  •  Foreign keys: {len(fks)}"
    )

    try:
        if action == "View":
            rows = run_select(f"SELECT * FROM {qident(table)}")
            st.dataframe(rows, use_container_width=True, hide_index=True)
            st.success(f"{len(rows)} record(s) retrieved from MySQL.")

        elif action == "Insert":
            st.subheader(f"➕ Insert {table} Record")
            with st.form(f"insert_form_{table}"):
                # value_widget uses Streamlit widgets and returns values immediately.
                values = {}
                for col in columns:
                    if is_generated(col) or is_auto_increment(col):
                        continue
                    fk = next((x for x in fks if x["COLUMN_NAME"] == col["COLUMN_NAME"]), None)
                    value, include = value_widget(table, col, mode="insert", fk=fk)
                    if include:
                        values[col["COLUMN_NAME"]] = clean_value(value)

                submitted = st.form_submit_button(
                    f"Insert {table}", type="primary", use_container_width=True
                )

            if submitted:
                if not values:
                    st.warning("No insertable fields were supplied.")
                else:
                    cols = list(values.keys())
                    sql = (
                        f"INSERT INTO {qident(table)} "
                        f"({', '.join(qident(c) for c in cols)}) "
                        f"VALUES ({', '.join(['%s'] * len(cols))})"
                    )
                    try:
                        _, new_id = run_action(sql, tuple(values[c] for c in cols))
                        st.success(f"Record inserted successfully. New ID: {new_id}")
                        st.cache_data.clear()
                    except Error as e:
                        st.error(f"Insert failed: {e}")

        elif action == "Update":
            rows = run_select(f"SELECT * FROM {qident(table)}")
            update_record(table, rows, columns, pk_cols, fks)

        elif action == "Delete":
            rows = run_select(f"SELECT * FROM {qident(table)}")
            delete_record(table, rows, pk_cols)

    except Error as e:
        st.error(f"Database error: {e}")

st.sidebar.divider()
st.sidebar.caption("14-table farm management database • MySQL + Streamlit")
