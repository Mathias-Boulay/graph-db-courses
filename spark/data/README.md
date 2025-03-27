
3.5.5

    Overview
    Programming Guides
    API Docs
    Deploying
    More

Quick Start

    Interactive Analysis with the Spark Shell
        Basics
        More on Dataset Operations
        Caching
    Self-Contained Applications
    Where to Go from Here

This tutorial provides a quick introduction to using Spark. We will first introduce the API through Spark’s interactive shell (in Python or Scala), then show how to write applications in Java, Scala, and Python.

To follow along with this guide, first, download a packaged release of Spark from the Spark website. Since we won’t be using HDFS, you can download a package for any version of Hadoop.

Note that, before Spark 2.0, the main programming interface of Spark was the Resilient Distributed Dataset (RDD). After Spark 2.0, RDDs are replaced by Dataset, which is strongly-typed like an RDD, but with richer optimizations under the hood. The RDD interface is still supported, and you can get a more detailed reference at the RDD programming guide. However, we highly recommend you to switch to use Dataset, which has better performance than RDD. See the SQL programming guide to get more information about Dataset.
Interactive Analysis with the Spark Shell
Basics

Spark’s shell provides a simple way to learn the API, as well as a powerful tool to analyze data interactively. It is available in either Scala (which runs on the Java VM and is thus a good way to use existing Java libraries) or Python. Start it by running the following in the Spark directory:

./bin/spark-shell

Spark’s primary abstraction is a distributed collection of items called a Dataset. Datasets can be created from Hadoop InputFormats (such as HDFS files) or by transforming other Datasets. Let’s make a new Dataset from the text of the README file in the Spark source directory:

scala> val textFile = spark.read.textFile("README.md")
textFile: org.apache.spark.sql.Dataset[String] = [value: string]

You can get values from Dataset directly, by calling some actions, or transform the Dataset to get a new one. For more details, please read the API doc.

scala> textFile.count() // Number of items in this Dataset
res0: Long = 126 // May be different from yours as README.md will change over time, similar to other outputs

scala> textFile.first() // First item in this Dataset
res1: String = # Apache Spark

Now let’s transform this Dataset into a new one. We call filter to return a new Dataset with a subset of the items in the file.

scala> val linesWithSpark = textFile.filter(line => line.contains("Spark"))
linesWithSpark: org.apache.spark.sql.Dataset[String] = [value: string]

We can chain together transformations and actions:

scala> textFile.filter(line => line.contains("Spark")).count() // How many lines contain "Spark"?
res3: Long = 15

More on Dataset Operations

Dataset actions and transformations can be used for more complex computations. Let’s say we want to find the line with the most words:

scala> textFile.map(line => line.split(" ").size).reduce((a, b) => if (a > b) a else b)
res4: Int = 15

This first maps a line to an integer value, creating a new Dataset. reduce is called on that Dataset to find the largest word count. The arguments to map and reduce are Scala function literals (closures), and can use any language feature or Scala/Java library. For example, we can easily call functions declared elsewhere. We’ll use Math.max() function to make this code easier to understand:

scala> import java.lang.Math
import java.lang.Math

scala> textFile.map(line => line.split(" ").size).reduce((a, b) => Math.max(a, b))
res5: Int = 15

One common data flow pattern is MapReduce, as popularized by Hadoop. Spark can implement MapReduce flows easily:

scala> val wordCounts = textFile.flatMap(line => line.split(" ")).groupByKey(identity).count()
wordCounts: org.apache.spark.sql.Dataset[(String, Long)] = [value: string, count(1): bigint]

Here, we call flatMap to transform a Dataset of lines to a Dataset of words, and then combine groupByKey and count to compute the per-word counts in the file as a Dataset of (String, Long) pairs. To collect the word counts in our shell, we can call collect:

scala> wordCounts.collect()
res6: Array[(String, Int)] = Array((means,1), (under,2), (this,3), (Because,1), (Python,2), (agree,1), (cluster.,1), ...)

Caching

Spark also supports pulling data sets into a cluster-wide in-memory cache. This is very useful when data is accessed repeatedly, such as when querying a small “hot” dataset or when running an iterative algorithm like PageRank. As a simple example, let’s mark our linesWithSpark dataset to be cached:

scala> linesWithSpark.cache()
res7: linesWithSpark.type = [value: string]

scala> linesWithSpark.count()
res8: Long = 15

scala> linesWithSpark.count()
res9: Long = 15

It may seem silly to use Spark to explore and cache a 100-line text file. The interesting part is that these same functions can be used on very large data sets, even when they are striped across tens or hundreds of nodes. You can also do this interactively by connecting bin/spark-shell to a cluster, as described in the RDD programming guide.
Self-Contained Applications

Suppose we wish to write a self-contained application using the Spark API. We will walk through a simple application in Scala (with sbt), Java (with Maven), and Python (pip).

We’ll create a very simple Spark application in Scala–so simple, in fact, that it’s named SimpleApp.scala:

/* SimpleApp.scala */
import org.apache.spark.sql.SparkSession

object SimpleApp {
def main(args: Array[String]): Unit = {
val logFile = "YOUR_SPARK_HOME/README.md" // Should be some file on your system
val spark = SparkSession.builder.appName("Simple Application").getOrCreate()
val logData = spark.read.textFile(logFile).cache()
val numAs = logData.filter(line => line.contains("a")).count()
val numBs = logData.filter(line => line.contains("b")).count()
println(s"Lines with a: $numAs, Lines with b: $numBs")
spark.stop()
}
}

Note that applications should define a main() method instead of extending scala.App. Subclasses of scala.App may not work correctly.

This program just counts the number of lines containing ‘a’ and the number containing ‘b’ in the Spark README. Note that you’ll need to replace YOUR_SPARK_HOME with the location where Spark is installed. Unlike the earlier examples with the Spark shell, which initializes its own SparkSession, we initialize a SparkSession as part of the program.

We call SparkSession.builder to construct a SparkSession, then set the application name, and finally call getOrCreate to get the SparkSession instance.

Our application depends on the Spark API, so we’ll also include an sbt configuration file, build.sbt, which explains that Spark is a dependency. This file also adds a repository that Spark depends on:

name := "Simple Project"

version := "1.0"

scalaVersion := "2.12.18"

libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.5.5"

For sbt to work correctly, we’ll need to layout SimpleApp.scala and build.sbt according to the typical directory structure. Once that is in place, we can create a JAR package containing the application’s code, then use the spark-submit script to run our program.

# Your directory layout should look like this
$ find .
.
./build.sbt
./src
./src/main
./src/main/scala
./src/main/scala/SimpleApp.scala

# Package a jar containing your application
$ sbt package
...
[info] Packaging {..}/{..}/target/scala-2.12/simple-project_2.12-1.0.jar

# Use spark-submit to run your application
$ YOUR_SPARK_HOME/bin/spark-submit \
--class "SimpleApp" \
--master local[4] \
target/scala-2.12/simple-project_2.12-1.0.jar
...
Lines with a: 46, Lines with b: 23

Other dependency management tools such as Conda and pip can be also used for custom classes or third-party libraries. See also Python Package Management.
Where to Go from Here

Congratulations on running your first Spark application!

    For an in-depth overview of the API, start with the RDD programming guide and the SQL programming guide, or see “Programming Guides” menu for other components.
    For running applications on a cluster, head to the deployment overview.
    Finally, Spark includes several samples in the examples directory (Scala, Java, Python, R). You can run them as follows:

# For Scala and Java, use run-example:
./bin/run-example SparkPi

# For Python examples, use spark-submit directly:
./bin/spark-submit examples/src/main/python/pi.py

# For R examples, use spark-submit directly:
./bin/spark-submit examples/src/main/r/dataframe.R

