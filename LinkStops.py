#!/usr/bin/env python3
import sqlite3

conSelect = sqlite3.connect("PAT_5")
conEdit = sqlite3.connect("PAT_5")

currSelect = conSelect.cursor()
currEdit = conEdit.cursor()

currSelect.execute("Select * From BusStopTBL")
for stop in currSelect:
    ID = stop[0]
    Location = stop[1]
    Name = stop[3]
    print(ID + "\n" + Location + "\n" + Name)
    Close = input("Stops nearby: ")
    print("================================== \n")
    try:
        currEdit.execute("Update BusStopTBL SET Close = ? Where BusStopID = ?",
                         (Close, ID))
    except sqlite3.Error:
        print("lol no")

conEdit.total_changes()
