create database d22hanol;
use d22hanol;

create table Incident(
    namn varchar(16),
    nr char(4),
    plats varchar(16),
    primary key (namn,nr)
)engine=innodb;

create table PåbörjadOperation(
  kodnamnTyp varchar(32),
  startdatum date,
  incidentNamn varchar(16),
  incidentNr char(4),
  foreign key (incidentNamn) references Incident(namn),
  foreign key (incidentNr) references Incident(Nr),
  primary key (kodnamnTyp,startdatum,incidentNr,incidentNamn)
)engine =innodb;

create table SlutfördOperation(
  kodnamnTyp varchar(32),
  startdatum date,
  slutdatum date,
  successRate char(1),
  incidentNamn varchar(16),
  incidentNr char(4),
  foreign key (incidentNamn) references Incident(namn),
  foreign key (incidentNr) references Incident(Nr),
  primary key (kodnamnTyp,startdatum,incidentNr,incidentNamn)
)engine =innodb;

create table Observation(
    ID char(8),
    säkerhet char(3),
    datum datetime,
    grad char(1),
    incidentNamn varchar(16),
    incidentNr char(4),
    primary key (ID),
    foreign key (incidentNamn) references Incident(namn),
    foreign key (incidentNr) references Incident(Nr)
)engine= innodb;

create index ObservationsID on Observation(ID asc) using btree;

create table alien(
    Hudfärg char(8),
    kläder varchar(25),
    typ varchar(25),
    storlek char (3),
    observation char(8),
    foreign key (observation) references Observation(ID),
    primary key (observation)
)engine=innodb;

create table rymdskepp(
    form char(8),
    lampor char(12),
    färg char(8),
    rörelse varchar(25),
    observation char(8),
    foreign key (observation) references Observation(id),
    primary key (observation)
)engine=innodb;

create table Media(
    namn varchar(10),
    kvalite char(8),
    observation char(8),
    foreign key (observation) references Observation(ID),
    primary key (namn,observation)
)engine= innodb;

create table MediaKommentar(
    kommentar varchar(128),
    namn varchar(10),
    observation char(8),
    foreign key (observation) references  Media(observation),
    foreign key (namn) references Media(namn),
    primary key (observation,namn)
)engine=innodb;

create table Person(
    ID char(13),
    namn varchar(25),
    kodnamn char(2),
    primary key (ID)
)engine=innodb;

create table PersonPåObservation(
    person char(13),
    observation char(8),
    foreign key (person) references Person(ID),
    foreign key (observation) references Observation(ID)
)engine=innodb;



