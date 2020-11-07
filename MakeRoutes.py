import sqlite3

conEdit = sqlite3.connect("PAT_5")
conSelect = sqlite3.connect("PAT_5")

curEdit = conEdit.cursor()
curSelect = conSelect.cursor()

print("             +++++++++++++++++++++++++++++++++++++")
print(" Select Route Code, enter stop names, enter blank to commit")
print("             +++++++++++++++++++++++++++++++++++++")

while True:
    stdin = input("Route Code: ")
    curSelect.execute("SELECT RouteID FROM RoutesTBL WHERE RouteID = ?",
                      (stdin,))
    result = curSelect.fetchone()
    if result is None:
        print("Route not found. Aborting!!!")
        continue

    curSelect.execute("SELECT Interval FROM RouteStopsTBL WHERE RouteID = ?"
                      " ORDER BY Interval DESC", (result[0],))
    intervaltime = curSelect.fetchone()
    if intervaltime is None:
        intervali = 0
    else:
        intervali = intervaltime[0]
    del(intervaltime)

    curSelect.execute("SELECT RoutePosition FROM RouteStopsTBL WHERE RouteID"
                      " = ? ORDER BY RoutePosition DESC", (result[0],))
    POS = curSelect.fetchone()
    if POS is None:
        routePosHID = 0
    else:
        routePosHID = int(POS[0]) + 1
    del(POS)
    while True:
        busStopName = input("Stop (" + str(routePosHID+1) +
                            "); Enter Stop Name: ")
        if busStopName == "":
            break
        curEdit.execute("Select BusStopID From BusStopTBL " +
                        "where Location = ?", (busStopName,))

        responce = curEdit.fetchone()
        busStopID = responce[0]
        if busStopID is None:
            print("Invalid Name")
            del(responce)
            continue
        del(responce)

        while True:
            interval = input("Select a interval (minutes), current(" +
                             str(intervali) + "): ")
            try:
                intervali = int(interval)
                del(interval)
                break
            except TypeError:
                print("Error invalid number, please enter a integer (1,2,3,"
                      "etc.)")
        curEdit.close()
        curEdit = conEdit.cursor()
        try:
            curEdit.execute("INSERT INTO RouteStopsTBL (RouteID, RoutePosition"
                            ", BusStopID, Interval) VALUES(?,?,?,?)",
                            (result[0], routePosHID, busStopID, intervali))
            conEdit.commit()
            routePosHID += 1
            print("Success")
        except sqlite3.DatabaseError:
            print("Something when't wrong and we don't know what lol.")
