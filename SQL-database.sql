drop database d22hanol;
create database d22hanol;
use d22hanol;

create table Incident(
    namn varchar(16),
    nr char(4),
    plats varchar(16),
    primary key (namn,nr)
)engine=innodb;
/* -----Coding____*/


create table PåbörjadOperation(
  kodnamnTyp varchar(32),
  kodnamnsKod int unique auto_increment,
  startdatum date,
  incidentNamn varchar(16),
  incidentNr char(4),
  foreign key (incidentNamn) references Incident(namn),
  foreign key (incidentNr) references Incident(nr),
  primary key (kodnamnTyp,startdatum,incidentNr,incidentNamn)
)engine =innodb;


create table SlutfördOperation(
  kodnamnTyp varchar(32),
  kodnamnskod int unique auto_increment ,
  startdatum date,
  slutdatum date,
  successRate bit ,
  incidentNamn varchar(16),
  incidentNr char(4),
  foreign key (incidentNamn) references Incident(namn),
  foreign key (incidentNr) references Incident(Nr),
  primary key (kodnamnTyp,startdatum,incidentNr,incidentNamn),
  check ( successRate = 1 or 2 or 3 or 4)
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

/* ----Merge ___*/ 

create table alienrymdskepp(
    alien boolean,
    rymdskepp boolean,
    Hudfärg char(8),
    kläder varchar(25),
    typ varchar(25),
    storlek char (3),
    form char(8),
    lampor char(12),
    färg char(8),
    rörelse varchar(25),
    observation char(8),
    foreign key (observation) references Observation(ID),
    primary key (observation),
    check ( if (alien = 1,
        rymdskepp = 0,
        form = NULL,
        lampor = NULL,
        färg = NULL,
        rörelse = NULL)),
    check ( if ( rymdskepp = 1,
        alien = 0,
        Hudfärg = NULL,
        kläder = NULL,
        typ = NULL,
        storlek = NULL))
)engine=innodb;

create table rymdskepp(

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

create table MediaLogg(
    ID smallint unsigned auto_increment,
    operation varchar(10),
    användarnamn varchar(32),
    nyaNamn varchar(10),
    gammalNamn varchar(10),
    optime datetime,
    primary key (ID)
)engine=innodb;

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

/* Index */
create index Observationsdatum on Observation(datum asc) using btree;

create index PåbörjadOperationsdatum on PåbörjadOperation(startdatum asc) using btree;
/* View */
Create VIEW BådaOperationer as
select kodnamnTyp,kodnamnsKod, startdatum, Null as "slutdatum", Null as "successRate", incidentNamn, incidentNr
from PåbörjadOperation
union
select kodnamnTyp,kodnamnskod, startdatum, slutdatum, successRate, incidentNamn, incidentNr
from SlutfördOperation;

create VIEW FullständigMedia as
select namn, kvalite, observation, Null as "kommentar"
from Media
union
select namn, Null as "kvalite", observation, kommentar
from MediaKommentar;

delimiter //
 /* procedure */
create procedure HämtaAllaPersoner()
begin
    select * from Person;
end //


create procedure HämtaOperationsnamn(in prod smallint)
begin
    select kodnamnTyp
    from BådaOperationer
        where kodnamnsKod=prod;
end //
 /* Trigger */
create trigger MediaTriggerInsert after insert on Media
    for each row begin
    insert into MediaLogg(operation, användarnamn, nyaNamn,gammalNamn, optime)
        values ('Insert',user(),new.namn,'-',now());
end //

create trigger MediaTriggerDelete after update on Media
    for each row begin
    insert into MediaLogg(operation, användarnamn, nyaNamn,gammalNamn, optime)
        values ('Update',user(),new.namn,old.namn,now());
end //

delimiter ;
 /* Rättigheter */
create user Gruppledare identified by 'Lösenord';
grant update on d22hanol.PåbörjadOperation to Gruppledare;
grant update on d22hanol.SlutfördOperation to Gruppledare;

