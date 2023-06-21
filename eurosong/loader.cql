// ***
// *** Database 
// ***
// *** CREATE DATABASE eurosong;


// ***
// *** Constraints
// ***

CREATE CONSTRAINT uc_Country_code IF NOT EXISTS FOR (c:Country) REQUIRE (c.code) IS UNIQUE;


// ***
// *** Nodes
// ***

// (:Country {code: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///eurosong/nodes/Country_fixed.csv" AS row
  WITH DISTINCT row.code as code
  RETURN code
','
  CREATE (:Country {code: code});
',{batchSize:2000, parallel:true});

// (:Country {code: String})-[:IS_NAMED {since: Date}]->(:CountryName {name: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///eurosong/nodes/Country_fixed.csv" AS row
  WITH row.code as code, row.englishname as name, Date(row.startdate) as startdate
  ORDER BY code, startdate
  RETURN code, name, startdate
','
  MATCH (c:Country {code: code})
  CREATE (cn:CountryName {name: name})
  CREATE (c)-[:IS_NAMED {since: Date(startdate)}]->(cn)
',{batchSize:2000, parallel:false});


// ***
// *** Relationships
// ***

CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///eurosong/relationships/VOTE_RELATIONSHIP.csv" AS row
  RETURN row
','
  MATCH (source:Country WHERE source.code = row.sourcecountrycode)
  MATCH (target:Country WHERE target.code = row.targetcountrycode)
  CALL apoc.create.relationship(source, row.relationshiptype, {weight: toInteger(row.weight)}, target) YIELD rel
  RETURN count(*);
',{batchSize:2000, parallel:false});


// ***
// *** Fix
// ***
MATCH (c:Country)-[in:IS_NAMED]->(cn:CountryName)
WITH c, in, cn
ORDER BY c.code, in.startdate DESC
WITH c, collect(cn.name) as names
SET c.name = names[0]
