drop database d22hanol;
create database d22hanol;
use d22hanol;

create table Incident(
    namn varchar(16),
    nr char(4),
    plats varchar(16),
    primary key (namn,nr),
    unique key idx_nr (nr),
    unique key idx_namn (namn)
)engine=innodb;

/* -----Coding-----*/
/* ----- vertical split ---*/

create table PåbörjadOperation(
  kodnamnTyp varchar(32),
  kodnamnsKod int unique auto_increment,
  startdatum date not null ,
  incident_Namn varchar(16),
  incident_Nr char(4),
  foreign key (incident_Namn) references Incident(namn),
  foreign key (incident_Nr) references Incident(nr),
  primary key (kodnamnTyp,startdatum,incident_Nr,incident_Namn)
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

create table ObservationsLogg(
    operation varchar(10),
    användarnamn varchar(32),
    optime datetime,
    ID int unsigned auto_increment primary key,
    observationsID char(8),
    säkerhet char(3),
    datum datetime,
    grad char(1),
    incidentNamn varchar(16),
    incidentNr char(4)

)engine=innodb;

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
    primary key (observation)
)engine=innodb;

/*---- Horizontal split ---*/

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
    Namn varchar(10),
    optime datetime,
    primary key (ID)
)engine=innodb;

create table MediaKommentar(
    kommentar varchar(80),
    namn varchar(10),
    observation char(8),
    foreign key (observation) references  Media(observation),
    foreign key (namn) references Media(namn),
    primary key (observation,namn)
)engine=innodb;

create table Person(
    ID char(13),
    check (ID rlike '[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
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
select kodnamnTyp,kodnamnsKod, startdatum, Null as "slutdatum", Null as "successRate", incident_Namn, incident_Nr
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
    insert into MediaLogg(operation, användarnamn, Namn, optime)
        values ('Insert',user(),new.namn,now());
end //

create trigger ObservationsDelete after delete on Observation
    for each row begin
    insert into ObservationsLogg(operation, användarnamn, optime, observationsID,säkerhet,datum, grad, incidentNamn, incidentNr)
        values ('Delete',user(),now(), old.ID, old.säkerhet, old.datum,old.grad,old.incidentNamn, old.incidentNr);
end //

CREATE TRIGGER UpdateAlienrymdskepp
BEFORE INSERT ON alienrymdskepp
FOR EACH ROW
BEGIN
    IF NEW.alien = 1 THEN
        SET NEW.rymdskepp = 0;
        SET NEW.form = NULL;
        SET NEW.lampor = NULL;
        SET NEW.färg = NULL;
        SET NEW.rörelse = NULL;
    END IF;
    if NEW.rymdskepp = 1 THEN
        set new.alien = 0;
        set new.Hudfärg = NULL;
        set new.kläder = NULL;
        set new.typ = NULL;
        set new.storlek = NULL;
    END IF;
END //

delimiter ;
 /* Rättigheter */
drop user Gruppledare;
create user Gruppledare identified by 'Lösenord';
grant select on d22hanol.PåbörjadOperation to Gruppledare;
grant select on d22hanol.SlutfördOperation to Gruppledare;
grant update on d22hanol.PåbörjadOperation to Gruppledare;
grant update on d22hanol.SlutfördOperation to Gruppledare;
grant select on d22hanol.BådaOperationer to Gruppledare;

grant execute on procedure d22hanol.hämtaallapersoner to Gruppledare;

grant insert on d22hanol.Media to Gruppledare;
grant select on d22hanol.Observation to Gruppledare;
grant delete on d22hanol.Observation to Gruppledare;

insert into Incident(namn, nr )
values ('inceldent',1);

insert into Observation(id, säkerhet, datum, grad, incidentnamn, incidentnr)
values ('båten',null,null,null,'inceldent',1),('example',10,now(),1,'inceldent',1);

select * from MediaLogg;

select * from ObservationsLogg;



