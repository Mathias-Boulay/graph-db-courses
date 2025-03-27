import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types.{StringType, StructType}


/* testes with the users csv
* -------------------------------------------
Batch: 0
-------------------------------------------
+---+---------+--------+
| id|treatment|location|
+---+---------+--------+
| id|     name|     age|
|  1|       P1|      28|
|  2|       P2|      22|
|  3|       P3|      30|
|  4|       P4|      25|
|  5|       P5|      35|
+---+---------+--------+
*/

object BasicFileStreaming extends App {

  val spark = SparkSession.builder()
    .appName("FileStreamingExample")
    .master("local[*]")
    .getOrCreate()

  spark.sparkContext.setLogLevel("ERROR")

  val schema = new StructType()
    .add("id", StringType)
    .add("treatment", StringType)
    .add("location", StringType)


  val streamingDF = spark.readStream
    .option("header", "false")
    .schema(schema)
    .csv("input/")

  val consoleQuery = streamingDF.writeStream
    .format("console")
    .outputMode("append") // each new file’s rows will appear in the console
    .start()

  val csvQuery = streamingDF.writeStream
    .format("csv")
    .outputMode("append")
    .option("path", "output/") // <--- Where final CSV files will be saved
    .option("checkpointLocation", "chkpoint/") // <--- Directory for checkpointing
    .start()

  spark.streams.awaitAnyTermination()
}
