#!/usr/bin/env python3
import sqlite3

conSelect = sqlite3.connect("PAT_5")
conEdit = sqlite3.connect("PAT_5")

currSelect = conSelect.cursor()
currEdit = conEdit.cursor()

currSelect.execute("Select * From BusStopTBL")
data = currSelect.fetchall()
for stop in data:
    ID = stop[0]
    Location = stop[1]
    IsAssigned = stop[2]
    Name = stop[3]
    try:
        if len(IsAssigned) > 1:
            continue
    except TypeError:
        print(ID + "\n" + Location + "\n" + Name)
        Closel = list()
        while True:
            iIn = input("Routes Connected: ")
            if len(iIn) < 1:
                break
            else:
                Closel.append(iIn)
        Close_names = " ("
        Close = ""
        for loc in Closel:
            responce = currEdit.execute("Select RouteID From RoutesTBL " +
                                        "where RouteID = ?", (loc,))
            result_raw = responce.fetchall()
            result = result_raw[0]
            if loc == Closel[len(Closel)-1]:
                Close = Close + result[0]
                print("Assigning codes: " + Close + Close_names + loc +
                      "); to " + Name + ":" + Location)

                confirm = input("Continue? (y/n): ")
                if confirm == 'y':
                    break
                else:
                    exit(0)

            Close = Close + result[0] + ','
            Close_names = Close_names + loc + ','
        print("================================== \n")
        try:
            currEdit.execute("Update BusStopTBL SET Close = ? Where BusStopID"
                             + " = ?", (Close, ID))
            conEdit.commit()
            print("Stop data Updated. Procceding to next item.\n")
            print("================================\n")
        except sqlite3.Error as error:
            print("lol no", error)
