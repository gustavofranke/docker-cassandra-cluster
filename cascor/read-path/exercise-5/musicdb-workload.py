#!/usr/bin/python

from cassandra.cluster import Cluster
from random import choice,randint,random
from uuid import uuid4
import os,string,sys,time,binascii

futures = []
cluster = Cluster(['127.0.0.1'])
session = cluster.connect()

album_read_all = session.prepare("SELECT * FROM musicdb.album")
album_read = session.prepare("SELECT * FROM musicdb.album WHERE title = ? AND year = ?")
album_update = session.prepare("UPDATE musicdb.album SET performer=?,genre=? WHERE title = ? AND year = ?")

performer_read_all = session.prepare("SELECT * FROM musicdb.performer")
performer_read = session.prepare("SELECT * FROM musicdb.performer WHERE name = ?")
performer_update = session.prepare("UPDATE musicdb.performer SET type=?,country=?,style=? WHERE name = ?")
performer_insert = session.prepare("INSERT INTO musicdb.performer (name,type,country,style,founded,born) VALUES (?,?,?,?,?,?)")

track_read_all = session.prepare("SELECT * FROM musicdb.tracks_by_album")
track_read = session.prepare("SELECT * FROM musicdb.tracks_by_album WHERE album_title = ? AND year = ? AND number = ?")
track_insert = session.prepare("INSERT INTO musicdb.tracks_by_album (album_title,year,number,track_title) VALUES (?,?,?,?)")
track_update = session.prepare("UPDATE musicdb.tracks_by_album SET track_title=? WHERE album_title = ? AND year = ? AND number = ?")

# album read
album=[]
rows = session.execute(album_read_all,[])
for row in rows:
  album.append([row.title,row.year])
for x in range(0,3000):
  i = randint(0,len(album)-1)
  if random() > 0.5:
    performer = ''.join(choice(string.lowercase) for i in range(20))
    genre = ''.join(choice(string.lowercase) for i in range(7))
    futures.append(session.execute_async(album_update,[performer,genre,album[i][0],album[i][1]]))
  else:
    futures.append(session.execute_async(album_read,album[i]))

# performer chance of read 0.1
performer=[]
rows = session.execute(performer_read_all,[])
for row in rows:
  performer.append(row.name)
for x in range(0,2):
  if random() > 0.9:
    futures.append(session.execute_async(performer_read,[performer[randint(0,len(performer)-1)]]))

# track write
for x in range(0,5000):
  album = ''.join(choice(string.lowercase) for i in range(20))
  year = randint(1900,2014)
  number = randint(1,20)
  title = ''.join(choice(string.lowercase) for i in range(15))
  futures.append(session.execute_async(track_insert,[album,year,number,title]))

for future in futures:
  future.result()

time.sleep(1)
cluster.shutdown()
