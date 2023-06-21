// ***
// *** Constraints
// ***
CREATE CONSTRAINT uc_Person_id IF NOT EXISTS FOR (p:Person) REQUIRE (p.id) IS UNIQUE;
CREATE CONSTRAINT uc_Session_id IF NOT EXISTS FOR (s:Session) REQUIRE (s.id) IS UNIQUE;
CREATE CONSTRAINT uc_Track_id IF NOT EXISTS FOR (t:Track) REQUIRE (t.id) IS UNIQUE;
CREATE CONSTRAINT uc_Subject_id IF NOT EXISTS FOR (s:Subject) REQUIRE (s.id) IS UNIQUE;

// ***
// *** Indexes
// ***
CREATE INDEX index_Person_name IF NOT EXISTS FOR (p:Person) ON (p.name);

// ***
// *** Nodes
// ***

// (:Person:Speaker {id: String, name: String, title: String, imageURL: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/nodes/Person.csv" AS row
  RETURN row
','
  CREATE (:Person:Speaker {id: row.id, name: row.name, title: apoc.text.base64Decode(row.title), imageURL: row.imageURL});
',{batchSize:2000, parallel:true});

// Verify Speaker nodes
MATCH (:Person&Speaker) RETURN count(*);

// (:Session {id: String, detail: String, title: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/nodes/Session.csv" AS row
  RETURN row
','
  CREATE (:Session {id: row.id, detail: apoc.text.base64Decode(row.detail), title: apoc.text.base64Decode(row.title)});
',{batchSize:2000, parallel:true});

// Verify Session nodes
MATCH (:Session) RETURN count(*);

// (:Track {id: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/nodes/Track.csv" AS row
  RETURN row
','
  CREATE (:Track {id: row.id});
',{batchSize:2000, parallel:true});

// Verify Track nodes
MATCH (:Track) RETURN count(*);

// (:Subject {id: String})
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/nodes/Subject.csv" AS row
  RETURN row
','
  CREATE (:Subject {id: row.id});
',{batchSize:2000, parallel:true});

// Verify Subject nodes
MATCH (:Subject) RETURN count(*);

// ***
// *** Relationships
// ***

// (:Person)-[:IS_SPEAKER_IN]->(:Session)
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/relationships/IS_SPEAKER_IN.csv" AS row
  RETURN row
','
  MATCH (source:Person {id: row.source})
  MATCH (target:Session {id: row.target})
  CREATE (source)-[:IS_SPEAKER_IN]->(target);
',{batchSize:2000, parallel:false});

// Verify IS_SPEAKER_IN relationships
MATCH (:Person)-[:IS_SPEAKER_IN]->(:Session) RETURN count(*);

// (:Session)-[:IS_PART_OF]->(:Track)
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/relationships/IS_PART_OF.csv" AS row
  RETURN row
','
  MATCH (source:Session {id: row.source})
  MATCH (target:Track {id: row.target})
  CREATE (source)-[:IS_PART_OF]->(target);
',{batchSize:2000, parallel:false});

// Verify IS_PART_OF relationships
MATCH (:Session)-[:IS_PART_OF]->(:Track) RETURN count(*);

// (:Person)-[:IS_ABOUT]->(:Subject)
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/relationships/IS_ABOUT.csv" AS row
  RETURN row
','
  MATCH (source:Person {id: row.source})
  MATCH (target:Subject {id: row.target})
  CREATE (source)-[:IS_ABOUT {relevance: toFloat(row.relevance)}]->(target);
',{batchSize:2000, parallel:false});

// Verify IS_ABOUT relationships
MATCH (:Person)-[:IS_ABOUT]->(:Subject) RETURN count(*);

// (:Person)-[:IS_TALKING_ABOUT]->(:Subject)
CALL apoc.periodic.iterate('
  LOAD CSV WITH HEADERS FROM "file:///GIDS/relationships/IS_TALKING_ABOUT.csv" AS row
  RETURN row
','
  MATCH (source:Person {id: row.source})
  MATCH (target:Subject {id: row.target})
  CREATE (source)-[:IS_TALKING_ABOUT {relevance: toFloat(row.relevance)}]->(target);
',{batchSize:2000, parallel:false});

// Verify IS_TALKING_ABOUT relationships
MATCH (:Person)-[:IS_TALKING_ABOUT]->(:Subject) RETURN count(*);
