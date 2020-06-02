#!/usr/bin/env python3
import sqlite3
import random

con = sqlite3.connect("PAT_5")
curr = con.cursor()

while input("Another?: ") == "y":
    hexID = random.randint(0, 16777215)
    ID = str(hex(hexID))
    ID = ID[2:]
    location = input("Location: ")
    name = "Stop "
    name = name + str(random.randint(100, 999))
    try:
        curr.execute("Insert INTO BusStopTBL VALUES(?, ?, ?, ?)", (ID,
                                                                   location,
                                                                   None,
                                                                   name))
        con.commit()
    except sqlite3.Error:
        print(" !!!ERROR!!! \n Unable to make modifications.")
