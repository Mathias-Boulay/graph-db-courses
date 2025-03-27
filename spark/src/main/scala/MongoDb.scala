import org.apache.spark.sql.SparkSession

object MongoDb {
  def main(args: Array[String]): Unit = {

    val username = "admin"
    val password = "password"
    val dbName = "admin"
    val collectionName = "system.version"

    val spark = SparkSession.builder()
      .appName("MongoDbTest")
      .config("spark.mongodb.read.connection.uri", s"mongodb://$username:$password@127.0.0.1/$dbName")
      .config("spark.mongodb.write.connection.uri", s"mongodb://$username:$password@127.0.0.1/$dbName")
      .master("local[*]")
      .getOrCreate()

    // Read from MongoDB
    val df = spark.read
      .format("mongodb")
      .option("collection", collectionName)
      .load()

    df.show()

    // Stop the Spark session
    spark.stop()

  }
}