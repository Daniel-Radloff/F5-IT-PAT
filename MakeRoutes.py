import sqlite3

conEdit = sqlite3.connect("PAT_5")
conSelect = sqlite3.connect("PAT_5")

curEdit = conEdit.cursor()
curSelect = conSelect.cursor()

while True:

