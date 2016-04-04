CREATE TABLE musicdb.performer (
  name VARCHAR,
  type VARCHAR,
  country VARCHAR,
  style VARCHAR,
  founded INT,
  born INT,
  died INT,
  PRIMARY KEY (name)
);

CREATE TABLE musicdb.performers_by_style (
  style VARCHAR,
  name VARCHAR,
  PRIMARY KEY (style, name)
);

CREATE TABLE musicdb.album (
  title VARCHAR,
  year INT,
  performer VARCHAR,
  genre VARCHAR,
  tracks MAP<INT,VARCHAR>,
  PRIMARY KEY ((title, year))
);

CREATE TABLE musicdb.albums_by_performer (
  performer VARCHAR,
  year INT,
  title VARCHAR,
  genre VARCHAR,
  PRIMARY KEY (performer, year, title)
) WITH CLUSTERING ORDER BY (year DESC, title ASC);

CREATE TABLE musicdb.albums_by_genre (
  genre VARCHAR,
  performer VARCHAR,
  year INT,
  title VARCHAR,
  PRIMARY KEY (genre, performer, year, title)
) WITH CLUSTERING ORDER BY (performer ASC, year DESC, title ASC);


CREATE TABLE musicdb.albums_by_track (
  track_title VARCHAR,
  performer VARCHAR,
  year INT,
  album_title VARCHAR,
  PRIMARY KEY (track_title, performer, year, album_title)
) WITH CLUSTERING ORDER BY (performer ASC, year DESC, album_title ASC);

CREATE TABLE musicdb.tracks_by_album (
  album_title VARCHAR,
  year INT,
  performer VARCHAR STATIC,
  genre VARCHAR STATIC,
  number INT,
  track_title VARCHAR,
  PRIMARY KEY ((album_title, year), number)
);
