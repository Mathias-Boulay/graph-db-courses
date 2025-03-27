MATCH (n:Person)
RETURN n;


/*
{
  "identity": 1,
  "labels": [
    "Person"
  ],
  "properties": {
    "name": "Mathias",
    "age": 22
  },
  "elementId": "4:1d64e303-2573-4762-9add-fece4e35d07b:1"
}
{
  "identity": 2,
  "labels": [
    "Person"
  ],
  "properties": {
    "name": "Mael",
    "age": 20
  },
  "elementId": "4:1d64e303-2573-4762-9add-fece4e35d07b:2"
}
*/

MATCH (n:Person)-[r:WRITES_CODE]->(p:Programming)
RETURN n, r, p;

MATCH (n:Person)-[r:WRITES_CODE]->(p:Programming)
RETURN n.name, r.experience, p.language;


MATCH (n:Person)-[r:WRITES_CODE]->(p:Programming)
WHERE r.experience = "confirmed"
RETURN n, r, p;


CALL db.schema.visualization;


MATCH (m:Movie)
RETURN m.title, m.released;

MATCH (m:Movie)<-[i:ACTED_IN]-(a:Person)
WITH m, collect(a) as Actors
WHERE size(Actors) > 2
RETURN m;


MATCH (m:Movie)
RETURN m.title, m.released
ORDER BY m.released ASC;

CREATE (:Person {born: 2002, name: "Mathias Boulay"});

// ---
MATCH (a:Person), (b:Movie)
WHERE a.name = 'Mathias Boulay' AND b.title = 'The Matrix'
CREATE (a)-[:ACTED_IN]->(b);


CALL apoc.load.json("file:///test_data.json") YIELD value;


/*
{
  "name": "Person 1",
  "age": 25
}
{
  "name": "Person 2",
  "age": 30
}
{
  "name": "Person 3",
  "age": 35
}
{
  "name": "Person 4",
  "age": 40
}
*/

WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND keys(value) AS key
RETURN key, apoc.meta.cypher.type(value[key]);


/*
"CVE_Items"	"LIST OF MAP"
"CVE_data_type"	"STRING"
"CVE_data_format"	"STRING"
"CVE_data_timestamp"	"STRING"
"CVE_data_numberOfCVEs"	"STRING"
"CVE_data_version"	"STRING"
*/

WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_data_numberOfCVEs as Cnt
RETURN Cnt;

/*
Cnt
"37388"
*/


WITH "file:///nvdcve-1.1-2024.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_Items as data
RETURN data limit 5;

/*
{
  "lastModifiedDate": "2024-09-27T14:08Z",
  "cve": {
    "data_version": "4.0",
    "references": {
      "reference_data": [
        {
          "tags": [
            "Vendor Advisory"
          ],
          "name": "https://purestorage.com/security",
          "refsource": "",
          "url": "https://purestorage.com/security"
        }
      ]
    },
    "data_type": "CVE",
    "description": {
      "description_data": [
        {
          "value": "A condition exists in FlashArray Purity whereby a local account intended for initial array configuration remains active potentially allowing a malicious actor to gain elevated privileges.",
          "lang": "en"
        }
      ]
    },
    "problemtype": {
      "problemtype_data": [
        {
          "description": [
            {
              "value": "CWE-1188",
              "lang": "en"
            }
          ]
        }
      ]
    },
    "data_format": "MITRE",
    "CVE_data_meta": {
      "ID": "CVE-2024-0001",
      "ASSIGNER": "psirt@purestorage.com"
    }
  },
  "configurations": {
    "nodes": [
      {
        "cpe_match": [
          {
            "versionStartIncluding": "6.4.0",
            "cpe23Uri": "cpe:2.3:a:purestorage:purity\/\/fa:*:*:*:*:*:*:*:*",
            "versionEndIncluding": "6.4.10",
            "vulnerable": true,
            "cpe_name": []
          },
          {
            "versionStartIncluding": "6.3.0",
            "cpe23Uri": "cpe:2.3:a:purestorage:purity\/\/fa:*:*:*:*:*:*:*:*",
            "versionEndIncluding": "6.3.14",
            "vulnerable": true,
            "cpe_name": []
          }
        ],
        "children": [],
        "operator": "OR"
      }
    ],
    "CVE_data_version": "4.0"
  },
  "publishedDate": "2024-09-23T18:15Z",
  "impact": {
    "baseMetricV3": {
      "impactScore": 5.9,
      "cvssV3": {
        "availabilityImpact": "HIGH",
        "vectorString": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H",
        "userInteraction": "NONE",
        "scope": "UNCHANGED",
        "attackVector": "NETWORK",
        "baseScore": 9.8,
        "privilegesRequired": "NONE",
        "baseSeverity": "CRITICAL",
        "integrityImpact": "HIGH",
        "attackComplexity": "LOW",
        "confidentialityImpact": "HIGH",
        "version": "3.1"
      },
      "exploitabilityScore": 3.9
    }
  }
}
*/

CALL apoc.periodic.iterate("CALL apoc.load.json('file:///nvdcve-1.1-2024.json') YIELD value",
"UNWIND  value.CVE_Items AS data  \r\n"+
"UNWIND data.cve.references.reference_data AS references \r\n"+
"MERGE (cveItem:CVE {uid: apoc.create.uuid()}) \r\n"+
"ON CREATE SET cveItem.cveid = data.cve.CVE_data_meta.ID, cveItem.references = references.url",
 {batchSize:100, iterateList:true});


MATCH (n) DETACH DELETE n;

LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS csvLine
RETURN count(csvLine);


/*
	count(csvLine)
3
*/

LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS csvLine
MERGE (country:Country { name: csvLine.country })
CREATE (movie:Movie { id: toInteger(csvLine.id), title: csvLine.title, year:toInteger(csvLine.year)})
CREATE (movie)-[:MADE_IN]->(country);



WITH "file:///stackoverflow.json" as url 
CALL apoc.load.json(url) YIELD value 
UNWIND  value.CVE_Items as data
RETURN data limit 5;



// https://api.stackexchange.com/2.2/questions?pagesize=100&order=desc&sort=creation&tagged=neo4j&site=stackoverflow&filter=!5-i6Zw8Y)4W7vpy91PMYsKM-k9yzEsSC1_Uxlf



