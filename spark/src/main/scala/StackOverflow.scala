import org.apache.spark.sql.{Dataset, SparkSession}
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types.{IntegerType, StringType, StructType}

object StackOverflow {
  def main(args: Array[String]): Unit = {

    val spark = SparkSession.builder()
      .appName("UsersTest")
      .config("spark.driver.memory", "8G")
      .master("local[*]")
      .getOrCreate()

    spark.sparkContext.setLogLevel("ERROR")

    val schema = new StructType()
      .add("postTypeId", IntegerType, nullable = true)
      .add("id", IntegerType, nullable = true)
      .add("acceptedAnswer", StringType, nullable = true)
      .add("parentId", IntegerType, nullable = true)
      .add("score", IntegerType, nullable = true)
      .add("tag", StringType, nullable = true)

    import spark.implicits._
    val overflow = spark.read
      .option("header", "false")
      .option("inferSchema", "true")
      .schema(schema)
      .csv("data/stackoverflow.csv")


    overflow.filter(col("score") > 20).orderBy(col("score").desc).show(5)

    println(
      //"Count acceptedAnswer null: "+ overflow.filter(col("acceptedAnswer").isNull).count()
      "\nCount tag null: "+ overflow.filter($"tag".isNull).count()
        + "\nCount parentId null: "+ overflow.filter($"parentId".isNull).count() )

    // Filter posts with a score greater than 10
    val highScorePosts = overflow
      .filter(col("score") > 20)

    highScorePosts.show(5)



    println(overflow.count())
    overflow.createOrReplaceTempView("stackoverflow")

    // Query 1: Top 5 highest scores
    val top5Scores = spark.sql("SELECT id, score FROM stackoverflow ORDER BY score DESC LIMIT 5")
    top5Scores.show()

    val top5ScoresWithTag = spark.sql("""
        SELECT id, score, tag
        FROM stackoverflow
        WHERE tag IS NOT NULL
        ORDER BY score DESC
        LIMIT 5
      """)
    top5ScoresWithTag.show()

    // Query: Most frequently used tags
    val popularTags = spark.sql("""
      SELECT tag, COUNT(*) as frequency
      FROM stackoverflow
      WHERE tag IS NOT NULL
      GROUP BY tag
      ORDER BY frequency DESC
      LIMIT 10
    """)

    /*
      val result = usersoverflow
        .filter($"age" >= 25)
        .groupBy("city")
        .agg(collect_list("name").as("names"))
        .select("city", "names")

      val resultCollected = result.collect()
      resultCollected.foreach { row =>
        val city = row.getAs[String]("city")
        val names = row.getAs[Seq[String]]("names")
        println(s"Users in $city: ${names.mkString(", ")}")
      }*/
    spark.stop()
  }
}
