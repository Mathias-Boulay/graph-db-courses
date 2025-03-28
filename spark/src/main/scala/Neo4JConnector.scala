import org.apache.spark.sql.{SparkSession}



object Neo4JConnector {
  def main(args: Array[String]): Unit = {

    // Replace with the actual connection URI and credentials
    val url = "neo4j://3.92.182.134" //"neo4j://localhost:7687"
    val username = "neo4j"
    val password = "[CENSORED]" // "tototata"
    val dbname = "neo4j" //"recommendations"

    val spark = SparkSession.builder
      .config("neo4j.url", url)
      .config("neo4j.authentication.basic.username", username)
      .config("neo4j.authentication.basic.password", password)
      .config("neo4j.database", dbname)
      .master("local[*]")
      .getOrCreate()

    val Q5 =
      """
        MATCH (:Client:FirstPartyFraudster)-[]-(txn:Transaction)-[]-(c:Client)
        WHERE NOT c:FirstPartyFraudster
        UNWIND labels(txn) AS transactionType
        RETURN transactionType, count(*) AS freq
      """.stripMargin

    val df5 = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", Q5)
      .load()

    df5.show()

    // Read from Neo4j
    val Q6 =

      """
     MATCH (c:Client)
WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
WITH *, size(fGroup) AS groupSize WHERE groupSize > 9
WITH collect(fpGroupID) AS fraudRings
MATCH p=(c:Client)-[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->()
WHERE c.firstPartyFraudGroup IN fraudRings
RETURN count(p)
      """

    val df6 = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", Q6)
      .load()

    df6.show()


    val Q7 =

      """
     MATCH (c:Client)
WITH c.firstPartyFraudGroup AS fpGroupID, collect(c.id) AS fGroup
WITH *, size(fGroup) AS groupSize WHERE groupSize > 10
WITH collect(fpGroupID) AS fraudRings
MATCH p=(c:Client)-[:HAS_SSN|HAS_EMAIL|HAS_PHONE]->()
WHERE c.firstPartyFraudGroup IN fraudRings
RETURN count(p)
      """

    val df7 = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", Q7)
      .load()

    df7.show()
  }
}

