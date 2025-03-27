ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.12.18"

lazy val root = (project in file("."))
  .settings(
    name := "spark"
  )


libraryDependencies += "org.apache.spark" %% "spark-core" % "3.5.5"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.5.5"
libraryDependencies += "org.apache.hadoop" % "hadoop-common" % "3.4.1"
libraryDependencies += "org.apache.hadoop" % "hadoop-aws" % "3.4.1"   // Hadoop AWS for MinIo
libraryDependencies += "org.neo4j" %% "neo4j-connector-apache-spark" % "5.3.1_for_spark_3"
libraryDependencies += "org.mongodb.spark" % "mongo-spark-connector_2.12" % "10.4.1"


assemblyMergeStrategy in assembly := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case x => MergeStrategy.first
}
