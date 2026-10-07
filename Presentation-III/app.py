import streamlit as st
import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

# =========================
# DATABASE CONNECTION
# =========================

def get_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME", "farm_management")
    )


# =========================
# DATABASE FUNCTIONS
# =========================

def get_farms():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            farm_id,
            farm_name,
            owner_name,
            location,
            total_area_acres
        FROM Farm
        ORDER BY farm_id
    """)

    farms = cursor.fetchall()

    cursor.close()
    connection.close()

    return farms


def insert_farm(farm_name, owner_name, location, area):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        INSERT INTO Farm
        (farm_name, owner_name, location, total_area_acres)
        VALUES (%s, %s, %s, %s)
    """, (farm_name, owner_name, location, area))

    connection.commit()

    new_id = cursor.lastrowid

    cursor.close()
    connection.close()

    return new_id


def delete_farm(farm_id):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "DELETE FROM Farm WHERE farm_id = %s",
        (farm_id,)
    )

    connection.commit()

    deleted_rows = cursor.rowcount

    cursor.close()
    connection.close()

    return deleted_rows


# =========================
# PAGE CONFIGURATION
# =========================

st.set_page_config(
    page_title="Farm Management System",
    page_icon="🌾",
    layout="wide"
)

st.title("🌾 Crop Planning & Farm Input Management System")
st.caption("MySQL Database Management System")


# =========================
# SIDEBAR
# =========================

st.sidebar.title("Operations")

operation = st.sidebar.radio(
    "Select Operation",
    [
        "View Farms",
        "Insert Farm",
        "Delete Farm"
    ]
)


# =========================
# VIEW
# =========================

if operation == "View Farms":

    st.header("📋 View Farm Records")

    try:
        farms = get_farms()

        if farms:
            st.dataframe(
                farms,
                use_container_width=True,
                hide_index=True
            )

            st.success(
                f"{len(farms)} farm record(s) retrieved from MySQL."
            )

        else:
            st.info("No farm records found.")

    except Error as e:
        st.error(f"Database connection error: {e}")


# =========================
# INSERT
# =========================

elif operation == "Insert Farm":

    st.header("➕ Insert New Farm")

    farm_name = st.text_input(
        "Farm Name",
        placeholder="e.g. Demo Farm"
    )

    owner_name = st.text_input(
        "Owner Name",
        placeholder="e.g. Sufiyan Yusuf"
    )

    location = st.text_input(
        "Location",
        placeholder="e.g. Hyderabad"
    )

    area = st.number_input(
        "Total Area (acres)",
        min_value=0.01,
        max_value=999999.99,
        value=10.00,
        step=0.01
    )

    if st.button("Insert Farm", type="primary"):

        if not farm_name or not owner_name or not location:
            st.warning("Please fill in all required fields.")

        else:
            try:
                new_id = insert_farm(
                    farm_name,
                    owner_name,
                    location,
                    area
                )

                st.success(
                    f"Farm inserted successfully! Farm ID: {new_id}"
                )

            except Error as e:
                st.error(f"Database error: {e}")


# =========================
# DELETE
# =========================

elif operation == "Delete Farm":

    st.header("🗑️ Delete Farm")

    farm_id = st.number_input(
        "Farm ID",
        min_value=1,
        step=1
    )

    st.warning(
        "Only delete a farm that has no dependent Field or Season records."
    )

    if st.button("Delete Farm", type="primary"):

        try:
            deleted_rows = delete_farm(farm_id)

            if deleted_rows > 0:
                st.success(
                    f"Farm ID {farm_id} deleted successfully."
                )
            else:
                st.warning(
                    f"No farm found with ID {farm_id}."
                )

        except Error as e:
            st.error(
                f"Could not delete the farm. "
                f"It may have related records. Database error: {e}"
            )