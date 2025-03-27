import org.apache.spark.sql.types.{IntegerType, StringType, StructType}
import org.apache.spark.sql.{DataFrame, SparkSession}

import scala.util.Random

object FileStreaming {
  def main(args: Array[String]): Unit = {
    val minioEndpoint = sys.env("MINIO_ENDPOINT")
    val minioAccessKey = sys.env("MINIO_ACCESS_KEY")
    val minioSecretKey = sys.env("MINIO_SECRET_KEY")
    val minioBucket = sys.env("MINIO_BUCKET")

    val spark = SparkSession.builder()
      .appName("FileStreaming")
      .master("local[*]")
      .config("spark.hadoop.fs.s3a.endpoint", minioEndpoint)
      .config("spark.hadoop.fs.s3a.access.key", minioAccessKey)
      .config("spark.hadoop.fs.s3a.secret.key", minioSecretKey)
      .config("spark.hadoop.fs.s3a.path.style.access", "true")
      .config("spark.hadoop.fs.s3a.connection.timeout", "5000")
      .config("spark.hadoop.fs.s3a.connection.establish.timeout", "5000")
      .getOrCreate()

    val userSchema = new StructType()
      .add("id", IntegerType)
      .add("name", StringType)
      .add("age", IntegerType)

    val usersDF = spark.readStream
      .option("header", "true")
      .schema(userSchema)
      .csv(s"s3a://$minioBucket/users/")

    val query = usersDF.writeStream
      .outputMode("append")
      .format("console")
      .start()

    query.awaitTermination()
  }
}