/* SimpleApp.scala */
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.collect_list

object SimpleCsvApp {
  /// Outputs
  /// [San Francisco,WrappedArray(P5)]
  /// [New York,WrappedArray(P1, P3)]
  /// [Boston,WrappedArray(P4)]
  ///
  def main(args: Array[String]): Unit = {
    var env = System.getenv("MINIO_URL")
    if (env == null || env.isEmpty || env.isBlank) {
      env = "http://localhost:9000"
    }
    val logFile = "s3a://bitbucket/users.csv" // Should be some file on your system
    val spark = SparkSession.builder
      .appName("Simple Application")
      .master("local[*]")
      .config("spark.hadoop.fs.s3a.access.key", "eslbyq31ttw5xadZ3lVj")
      .config("spark.hadoop.fs.s3a.secret.key", "40PJiigIOtctB4rVD7ijwujb6FbHXEZfkjN7Lhzi")
      .config("spark.hadoop.fs.s3a.endpoint", env)
      .config("spark.hadoop.fs.s3a.path.style.access", "true")
      .getOrCreate()

    val userDf = spark
      .read
      .option("header", "true")
      .option("infoSchema", "true")
      .csv(logFile).cache()

    import spark.implicits._
    val result = userDf
      .filter($"age" >= 25)
      .groupBy("city")
      .agg(collect_list("name").as("names"))
      .select("city", "names")

    val resultCollected = result.collect();
    resultCollected.foreach(it => {
      println(it)
    })

    //val numAs = logData.filter(line => line.contains("a")).count()
    //val numBs = logData.filter(line => line.contains("b")).count()
    //println(s"Lines with a: $numAs, Lines with b: $numBs")
    spark.stop()
  }
}