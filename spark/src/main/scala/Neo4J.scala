import org.apache.spark.sql.{SparkSession}



object Neo4J {
  def main(args: Array[String]): Unit = {

    // Replace with the actual connection URI and credentials
    val url = "neo4j://localhost:7687"
    val username = "neo4j"
    val password = "tototata"
    val dbname = "recommendations"

    val spark = SparkSession.builder
      .config("neo4j.url", url)
      .config("neo4j.authentication.basic.username", username)
      .config("neo4j.authentication.basic.password", password)
      .config("neo4j.database", dbname)
      .master("local[*]")
      .getOrCreate()

    // Read from Neo4j
    val readQuery =

      """
      MATCH (n)
      RETURN COUNT(n)
      """

    val df = spark.read
      .format("org.neo4j.spark.DataSource")
      .option("query", readQuery)
      .load()

    df.show()
    /*
    *
    * +--------+
|COUNT(n)|
+--------+
|      29|
+--------+
    */
  }
}

