import org.apache.log4j.{Level, Logger}
import org.apache.spark.sql.types.{IntegerType, StringType, StructType}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.expressions.Log

object KafkaFileStreaming {
  def main(args: Array[String]): Unit = {
    val minioEndpoint = "http://localhost:9000"
    val minioAccessKey = "OGj4eylYsV97vsLmEDM4"
    val minioSecretKey = "Bi8GTzsj8Ox1XCwAa0MOAlGakp4nNsue8SLmLJW7"
    val bucket = "bitbucket"

    val spark = SparkSession.builder()
      .appName("KafkaFileStreaming")
      .master("local[*]")
      .getOrCreate()



    val sc = spark.sparkContext
    sc.setLogLevel("ERROR")
    sc.hadoopConfiguration.set("fs.s3a.connection.timeout", "10000")
    sc.hadoopConfiguration.set("fs.s3a.connection.establish.timeout", "10000")
    sc.hadoopConfiguration.set("fs.s3a.endpoint", minioEndpoint)
    sc.hadoopConfiguration.set("fs.s3a.access.key", minioAccessKey)
    sc.hadoopConfiguration.set("fs.s3a.secret.key", minioSecretKey)
    sc.hadoopConfiguration.set("fs.s3a.path.style.access", "true")


    val userSchema = new StructType()
      .add("id", IntegerType)
      .add("name", StringType)
      .add("age", IntegerType)

    val usersDF = spark.readStream
      .option("header", "true")
      .schema(userSchema)
      .csv(s"s3a://$bucket/input/")

    val infiniteQuery = usersDF.writeStream
      .outputMode("append")
      .format("console")
      .start()

    infiniteQuery.awaitTermination()
  }
}