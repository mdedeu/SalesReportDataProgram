CREATE TABLE yearT (
        anio INTEGER,
        bisiesto BOOLEAN,
        PRIMARY KEY(anio)
);

CREATE TABLE semester (
        semestre INTEGER CHECK (semestre IN (1, 2)),
        anio INTEGER,
        semID INTEGER,
        FOREIGN KEY (anio) REFERENCES yearT,
        PRIMARY KEY(semID),
        UNIQUE(anio, semestre)
);

CREATE TABLE quarter (
        trimestre INTEGER CHECK (trimestre IN (1, 2, 3, 4)),
        semID INTEGER,
        trimID INTEGER,
        FOREIGN KEY (semID) REFERENCES semester,
        PRIMARY KEY(trimID),
        UNIQUE(trimestre, semID)
);

CREATE TABLE monthT (
        mes INTEGER CHECK (mes BETWEEN 1 AND 12),
        trimID INTEGER,
        nombre TEXT CHECK (nombre IN ('Jan', 'Feb', 'Mar', 'April', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec')),
        mesID INTEGER,
        FOREIGN KEY (trimID) REFERENCES quarter,
        PRIMARY KEY(mesID),
        UNIQUE(mes, trimID)
);

CREATE TABLE dayT (
        dia INTEGER,
        mesID INTEGER,
        diaID INTEGER,
        nombre TEXT CHECK (nombre IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),
        finde BOOLEAN,
        FOREIGN KEY (mesID) REFERENCES monthT,
        PRIMARY KEY(diaID),
        UNIQUE(dia, mesID)
);

----------------------------------------------------------------------

CREATE TABLE definitiva (
        id INTEGER,
        year_birth INTEGER NOT NULL,
        education TEXT NOT NULL CHECK (education IN ('2n Cycle', 'Basic', 'Graduation', 'Master', 'PhD')),
        marital_status TEXT NOT NULL CHECK( marital_status IN ('Absurd', 'Alone', 'Divorced', 'Married', 'Single', 'Together', 'Widow')),
        income INTEGER,
        kidhome INTEGER NOT NULL,
        teenhome INTEGER NOT NULL,
        diaID INTEGER NOT NULL, --hace ref a diaT. Trigger en dt_customer
        recency INTEGER NOT NULL,
        mnt_wines INTEGER NOT NULL,
        mnt_fruits INTEGER NOT NULL,
        mnt_meat INTEGER NOT NULL,
        mnt_fish INTEGER NOT NULL,
        mnt_sweet INTEGER NOT NULL,
        num_deals_purchases INTEGER NOT NULL,
        num_web_purchases INTEGER NOT NULL,
        num_catalog_purchases INTEGER NOT NULL,
        num_stores_purchases INTEGER NOT NULL,
        PRIMARY KEY(id),
        FOREIGN KEY (diaID) REFERENCES dayT
);

CREATE TABLE intermedia (
        id INTEGER,
        year_birth INTEGER,
        education TEXT,
        marital_status TEXT,
        income INTEGER,
        kidhome INTEGER,
        teenhome INTEGER,
        dt_customer DATE, 
        recency INTEGER,
        mnt_wines INTEGER,
        mnt_fruits INTEGER,
        mnt_meat INTEGER,
        mnt_fish INTEGER,
        mnt_sweet INTEGER,
        num_deals_purchases INTEGER,
        num_web_purchases INTEGER,
        num_catalog_purchases INTEGER,
        num_stores_purchases INTEGER,
        PRIMARY KEY(id)
);

---------------------------------------------------------------

CREATE OR REPLACE FUNCTION bisiesto( yearP yearT.anio%type)
RETURNS BOOLEAN AS $$
BEGIN
        IF yearP % 4 = 0 THEN
                IF yearP % 100 <> 0 THEN
                        RETURN TRUE;
                END IF;
                IF yearP % 400 = 0 THEN
                        RETURN TRUE;
                END IF;
        END IF;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_semID(semP semester.semestre%type, yearP yearT.anio%type )
RETURNS INTEGER AS $$
DECLARE
        foundSem INTEGER;
        nextSemID INTEGER;
       
BEGIN
        SELECT semID INTO foundSem
        FROM semester
        WHERE semestre = semP and anio = yearP;
        
        IF foundSem IS NULL THEN
             SELECT COUNT(*) INTO nextSemID
             FROM semester;
             INSERT INTO semester VALUES (semP, yearP, nextSemID + 1);
             RETURN nextSemID + 1;
        END IF; 
        RETURN foundSem;
            
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_trimID(trimP quarter.trimestre%type, semP quarter.semID%type)
RETURNS INTEGER AS $$
DECLARE
        foundTri INTEGER;
        nextTriID INTEGER;
       
BEGIN
        SELECT trimID INTO foundTri
        FROM quarter
        WHERE trimestre = trimP and semID = semP;
        
        IF foundTri IS NULL THEN
             SELECT COUNT(*) INTO nextTriID
             FROM quarter;
             INSERT INTO quarter VALUES (trimP, semP, nextTriID + 1);
             RETURN nextTriID + 1;
        ELSE
                RETURN foundTri;
        END IF;
        
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_mesID(monthP monthT.mes%type, trimP monthT.trimID%type)
RETURNS INTEGER as $$
DECLARE 
        mName monthT.nombre%type;
        foundMes INTEGER;
        nextMesID INTEGER;
        
BEGIN
        SELECT mesID INTO foundMes
        FROM monthT
        WHERE mes = monthP and trimID = trimP;
        
        IF foundMes IS NULL THEN
             SELECT COUNT(*) INTO nextMesID
             FROM monthT;
             CASE
                when monthP = 01 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Jan', nextMesID + 1);
                when monthP = 02 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Feb', nextMesID + 1);
                when monthP = 03 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Mar', nextMesID + 1);
                when monthP = 04 THEN INSERT INTO monthT VALUES (monthP, trimP, 'April', nextMesID + 1);
                when monthP = 05 THEN INSERT INTO monthT VALUES (monthP, trimP, 'May', nextMesID + 1);
                when monthP = 06 THEN INSERT INTO monthT VALUES (monthP, trimP, 'June', nextMesID + 1);
                when monthP = 07 THEN INSERT INTO monthT VALUES (monthP, trimP, 'July', nextMesID + 1);
                when monthP = 08 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Aug', nextMesID + 1);
                when monthP = 09 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Sept', nextMesID + 1);
                when monthP = 10 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Oct', nextMesID + 1);
                when monthP = 11 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Nov', nextMesID + 1);
                when monthP = 12 THEN INSERT INTO monthT VALUES (monthP, trimP, 'Dec', nextMesID + 1);
             END CASE;
             RETURN nextMesID + 1;
        END IF;
        RETURN foundMes;
               
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION get_diaID(diaP dayT.dia%type, mesIDP dayT.mesID%type, weekDayP INT)
RETURNS INTEGER as $$
DECLARE 
        mName dayT.nombre%type;
        foundDia INTEGER;
        nextDiaID INTEGER;
        
BEGIN
        SELECT diaID INTO foundDia
        FROM dayT
        WHERE dia = diaP and mesID = mesIDP;

        IF foundDia IS NULL THEN
             SELECT COUNT(*) INTO nextDiaID
             FROM dayT;
             CASE
                when weekDayP = 0 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Sun', true); --hay que ver cual viene primero
                when weekDayP = 1 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Mon', false);
                when weekDayP = 2 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Tue', false);
                when weekDayP = 3 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Wed', false);
                when weekDayP = 4 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Thu', false);
                when weekDayP = 5 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Fri', false);
                when weekDayP = 6 THEN INSERT INTO dayT VALUES (diaP, mesIDP, nextDiaID + 1, 'Sat', true);
             END CASE;
             RETURN nextDiaID + 1;
        ELSE
                RETURN foundDia;
        END IF;
               
END;
$$ language plpgsql;

set datestyle to MDY;

CREATE OR REPLACE FUNCTION load_dates(fechaP DATE)
RETURNS INTEGER AS $$
DECLARE
        yearV yearT.anio%type;
        trimV quarter.trimestre%type;
        monthV monthT.mes%type;
        dayV dayT.dia%type;
        bisV yearT.bisiesto%type;
        semIDV semester.semID%type;
        trimIDV quarter.trimID%type;
        mesIDV monthT.mesID%type;
        weekdayV INTEGER;
        foundYear INTEGER;
BEGIN
--01/01/2021
        
         yearV := EXTRACT(year from fechaP);
         trimV := EXTRACT(quarter from fechaP);
         monthV := EXTRACT(month from fechaP);
         dayV := EXTRACT(day from fechaP);
         weekdayV := EXTRACT(dow from fechaP);
         
         bisV := bisiesto(yearV);
        SELECT COUNT(*) INTO foundYear
        FROM yearT
        WHERE anio = yearV;
        IF foundYear = 0 THEN
                INSERT INTO yearT VALUES (yearV, bisV);
        END IF;
        --sem
        IF monthV >= 7 THEN
                semIDV := get_semID(2, yearV);
        ELSE 
                semIDV := get_semID(1, yearV);
        END IF;
        --trim
        trimIDV := get_trimID(trimV, semIDV);
        
        --month
        mesIDV := get_mesID(monthV, trimIDV);
        --day 
        RETURN get_diaID(dayV, mesIDV, weekdayV);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION load_table()
RETURNS trigger AS $load_table$
DECLARE 
        IDdia definitiva.diaID%type;
BEGIN
        IDdia := load_dates(new.dt_customer);
        INSERT INTO definitiva VALUES (CAST(new.id AS int), CAST(new.year_birth AS int), new.education, new.marital_status, CAST(new.income AS int), CAST(new.kidhome AS int),
        CAST(new.teenhome AS int), IDdia, CAST(new.recency AS int), CAST(new.mnt_wines AS int), CAST(new.mnt_fruits AS int), CAST(new.mnt_meat AS int), CAST(new.mnt_fish AS int),
        CAST(new.mnt_sweet AS int), CAST(new.num_deals_purchases AS int), CAST(new.num_web_purchases AS int), CAST(new.num_catalog_purchases AS int), CAST(new.num_stores_purchases AS int));
        RETURN new;
END;
$load_table$ LANGUAGE plpgsql;

CREATE TRIGGER load_table
AFTER INSERT OR UPDATE ON intermedia
FOR EACH ROW
EXECUTE PROCEDURE load_table();
CREATE OR REPLACE FUNCTION ReporteConsolidado(years int ) RETURNS void AS $$
    DECLARE 
        currentYear int;
        auxiChar char(4);
        auxi RECORD;
        auxiYear RECORD;
        category2 TEXT;
        recency2 INTEGER;
        frecuency2 INTEGER;
        monetary2 INTEGER;
        totalRecency INTEGER;
        totalMonetary INTEGER;
        totalFrecuency INTEGER;
        yearV INT;
        

cursor_year CURSOR FOR (
            SELECT
            CAST(yearT.anio AS CHAR(4)) as year,
            AVG(recency) as recency,
            AVG(num_catalog_purchases+num_deals_purchases+num_stores_purchases+num_web_purchases) as frecuency,
            AVG(mnt_wines+mnt_fruits+mnt_meat+mnt_fish+mnt_sweet) as monetary
            FROM definitiva
                JOIN dayT ON definitiva.diaID = dayT.diaID
                JOIN monthT ON monthT.mesID = dayT.mesID
                JOIN quarter ON quarter.trimID = monthT.trimID
                JOIN semester ON semester.semID = quarter.semID
                JOIN yearT ON semester.anio = yearT.anio
            GROUP BY yearT.anio
            ORDER BY yearT.anio
        );



cursor_birth CURSOR FOR(
          SELECT (
                CASE
                WHEN 2016-year_birth < 25 THEN 'Birth range: 1) - de 25'
                WHEN 2016-year_birth < 40 THEN 'Birth range: 2) de 25 a 39'
                WHEN 2016-year_birth < 50 THEN 'Birth range: 3) de 40 a 49'
                WHEN 2016-year_birth < 70 THEN 'Birth range: 4) de 50 a 69'
                ELSE 'Birth range: 5) + de 70'
                END
                ) AS category,
            AVG(recency) as recency,
            AVG(num_catalog_purchases+ num_deals_purchases+num_stores_purchases+num_web_purchases) as frecuency,
            AVG(mnt_wines+mnt_fruits+mnt_meat+mnt_fish+mnt_sweet) as monetary
            FROM definitiva
                JOIN dayT ON definitiva.diaID = dayT.diaID
                JOIN monthT ON monthT.mesID = dayT.mesID
                JOIN quarter ON quarter.trimID = monthT.trimID
                JOIN semester ON semester.semID = quarter.semID
                JOIN yearT ON semester.anio = yeart.anio
            WHERE yearT.anio = currentYear
            GROUP BY category  
);
              

cursor_education CURSOR FOR(
    SELECT 'Education: ' || education AS category,
            AVG(recency) as recency,
            AVG(num_catalog_purchases+num_deals_purchases+num_stores_purchases+num_web_purchases) as frecency,
            AVG(mnt_wines+mnt_fruits+mnt_meat+mnt_fish+mnt_sweet) as monetary
            FROM definitiva
                JOIN dayT ON definitiva.diaID = dayT.diaID
                JOIN monthT ON monthT.mesID = dayT.mesID
                JOIN quarter ON quarter.trimID = monthT.trimID
                JOIN semester ON semester.semID = quarter.semID
                JOIN yearT ON semester.anio = yearT.anio
            WHERE yearT.anio = currentYear
            GROUP BY category
);
   


cursor_maritalStatus CURSOR FOR(SELECT 'Marital status: ' || Marital_Status AS category,
            AVG(recency) as recency,
            AVG(num_catalog_purchases+num_deals_purchases+num_stores_purchases+num_web_purchases) as frecuency,
            AVG(mnt_wines+mnt_fruits+mnt_meat+mnt_fish+mnt_sweet) as monetary
            FROM definitiva
                JOIN dayT ON definitiva.diaID = dayT.diaID
                JOIN monthT ON monthT.mesID = dayT.mesID
                JOIN quarter ON quarter.trimID = monthT.trimID
                JOIN semester ON semester.semID = quarter.semID
                JOIN yearT ON semester.anio = yearT.anio
            WHERE yearT.anio = currentYear
            GROUP BY marital_Status
        ORDER BY category); 
    

cursor_income CURSOR FOR(
        SELECT (
                CASE
                WHEN income > 100000 THEN 'Income Range: 1) + de 100k'
                WHEN income > 70000 THEN 'Income Range: 2) Entre 70k y 100k'
                WHEN income > 30000 THEN 'Income Range: 3) Entre 30k y 70k'
                WHEN income >= 10000 THEN 'Income Range: 4) Entre 10k y 30k'
                ELSE 'Income Range: 5) Menos de 10k'
                END
                ) AS category,
            AVG(recency)as recency,
            AVG(num_catalog_purchases+num_deals_purchases+num_stores_purchases+num_web_purchases) as frecuency,
            AVG(mnt_wines+mnt_fruits+mnt_meat+mnt_fish+mnt_sweet) as monetary
            FROM definitiva
                JOIN dayT ON definitiva.diaID = dayT.diaID
                JOIN monthT ON monthT.mesID = dayT.mesID
                JOIN quarter ON quarter.trimID = monthT.trimID
                JOIN semester ON semester.semID = quarter.semID
                JOIN yearT ON semester.anio = yearT.anio
            WHERE yearT.anio = currentYear
            GROUP BY category
);
      
BEGIN
            OPEN cursor_year;
            LOOP
            FETCH cursor_year INTO yearV, totalRecency,totalFrecuency, totalMonetary ;
            EXIT WHEN NOT FOUND OR (years <= 0);
            IF currentYear IS NULL THEN
                BEGIN
                    raise info '-------------------------------------Consolidated Customer Report-------------------------------';
                    raise info 'Year-----Category--------------------------Recency-Frecuency-Monetary-------------------------';
                END;
            END IF;
            raise info '--------------------------------------------------------------------------------------------------';
                currentYear := yearV;
                auxiChar := CAST( currentYear AS CHAR(4));
                OPEN cursor_birth;
                LOOP
                    FETCH cursor_birth INTO category2, recency2, frecuency2, monetary2;
                    EXIT WHEN NOT FOUND;
                    raise info '%       %                          %    %   %', auxiChar, category2, recency2, frecuency2, monetary2;
                    auxiChar := '---';
                    
                END LOOP;
                CLOSE cursor_birth;

                OPEN cursor_education;
                LOOP
                    FETCH cursor_education INTO category2, recency2, frecuency2, monetary2;
                    EXIT WHEN NOT FOUND;
                    raise info '%       %                          %    %   %', auxiChar, category2, recency2, frecuency2, monetary2;
                    auxiChar := '---';
                   
                    
                END LOOP;
                CLOSE cursor_education;
                
                OPEN cursor_income;
                LOOP
                    FETCH cursor_income INTO category2, recency2, frecuency2, monetary2;
                    EXIT WHEN NOT FOUND;
                    raise info '%       %                          %    %   %', auxiChar, category2, recency2, frecuency2, monetary2;
                    auxiChar := '---';
                    
                END LOOP;
                CLOSE cursor_income;
                
                OPEN cursor_maritalStatus;
                LOOP
                    FETCH cursor_maritalStatus INTO category2, recency2, frecuency2, monetary2;
                    EXIT WHEN NOT FOUND;
                    raise info '%       %                          %    %   %', auxiChar, category2, recency2, frecuency2, monetary2;
                    auxiChar := '---';
                    
                 END LOOP;
                CLOSE cursor_maritalStatus;

            years := years-1;
            raise info '------------------------------------------------------------------------------------% % %', totalRecency, totalFrecuency, totalMonetary;

            END LOOP;
            CLOSE cursor_year;
END

$$ LANGUAGE plpgsql;
