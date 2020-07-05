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
    if len(result[0]) <= 1:
        print("Route not found. Aborting!!!")
        continue
    intervali = 0

    while True:
        routePosHID = 0
        busStopName = input("Stop (" + routePosHID+1 + "); Enter Stop Name: ")
        currEdit.execute("Select BusStopID From BusStopTBL " +
                         "where Location = ?", (busStopName,))

        responce.fetchone()
        busStopID = responce[0]
        del(responce)

        while True:
            interval = input("Select a interval, current(" + intervali + "): ")
            try:
                intervali = int(interval)
                break
            except TypeError:
                print("Error invalid number, please enter a integer (1,2,3,"
                      "etc.)")
        try:
            curEdit.execute("INSERT INTO RouteStopsTBL (RouteID, RoutePosition"
                            ", BusStopID, Interval) VALUES(?,?,?,?)",
                            (result[0], routePosHID-1,busStopID,intervali))
        except sqlite3.DatabaseError:
            print("Something when't wrong and we don't know what lol.")
        routePosHID =+1
