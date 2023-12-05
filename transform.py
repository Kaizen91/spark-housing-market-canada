from pyspark.sql import SparkSession

#####  ENTER BUCKET NAME HERE #####

BUCKET_NAME = "spark_housing"

###################################


def load_df(df, table_name):
    df.write.format("bigquery")\
                .option("table", table_name)\
                .option("dataset", "housing_datamart")\
                .option("temporaryGcsBucket", BUCKET_NAME)\
                .save()


if __name__ == "__main__":

    spark = SparkSession.builder.appName("housing-pipeline").getOrCreate()
    df = spark.read.csv("gs://spark_housing/LZ/source_housing_data.csv", header=True)
    df.createOrReplaceTempView("raw_canada_housing_data")

    # original table minus lat and long
    sql = """
    select
    cast(City as string) city
    ,cast(Price as double) price
    ,cast(Address as string) address
    ,cast(Number_Beds as int) num_of_beds
    ,cast(Number_Baths as int) num_of_baths
    ,cast(Province as string) province
    ,cast(Population as int) population
    ,cast(Median_Family_Income as double) median_family_income

    from raw_canada_housing_data
    """
    res = spark.sql(sql)
    res.createOrReplaceTempView("canada_housing_data")
    load_df(res, "canada_housing_data")

    # total value of the market in each city
    sql = """
    select
    city
    ,province
    ,cast(sum(price) as bigint) as market_value
    from canada_housing_data
    group by
    city
    ,province
    """
    res = spark.sql(sql)
    load_df(res, "market_value_by_city")

    # average home price per province ranked
    sql = """
    select
    province
    ,cast(round(avg(price)) as int) as average_price
    from canada_housing_data
    group by
    province
    order by
    average_price
    """
    res = spark.sql(sql)
    load_df(res, "home_price_by_province_ranked")

    # average home price per city ranked
    sql = """
    with canada_housing_data_average as (
    select
    city
    ,province
    ,avg(price) as average_price
    from canada_housing_data
    group by
    city,
    province
    )

    select
    city
    ,province
    ,average_price
    ,row_number() over(partition by province order by average_price) as rank
    from canada_housing_data_average
    """

    res = spark.sql(sql)
    load_df(res, "average_home_price_city_ranked")

    # median family income as a percentage of the average home price
    sql = """
    with canada_housing_data_average as (
    select
    city
    ,province
    ,avg(price) as average_price
    ,median_family_income
    from canada_housing_data
    group by
    city,
    province,
    median_family_income
    ),
    income_vs_price (
    select
    city,
    province,
    average_price,
    median_family_income,
    cast(median_family_income / average_price as double) as percent_of_average_price
    from canada_housing_data_average
    )
    select
    city,
    province,
    average_price,
    median_family_income,
    percent_of_average_price,
    row_number() over(partition by province order by percent_of_average_price desc) as rank
    from income_vs_price
    order by percent_of_average_price desc
    """
    res = spark.sql(sql)
    load_df(res, "income_vs_price_ranked")
