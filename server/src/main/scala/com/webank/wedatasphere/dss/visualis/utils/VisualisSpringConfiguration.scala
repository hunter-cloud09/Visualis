package com.webank.wedatasphere.dss.visualis.utils

import com.webank.wedatasphere.dss.visualis.entrance.spark.VisualisCSEntranceInterceptor
import org.apache.linkis.entrance.conf.EntranceConfiguration.ENTRANCE_SCHEDULER_MAX_PARALLELISM_USERS
import org.apache.linkis.entrance.interceptor.EntranceInterceptor
import org.apache.linkis.entrance.interceptor.impl._
import org.apache.linkis.entrance.persistence.PersistenceManager
import org.apache.linkis.entrance.scheduler.EntranceSchedulerContext
import org.apache.linkis.entrance.scheduler.cache.ReadCacheConsumerManager
import org.apache.linkis.scheduler.executer.ExecutorManager
import org.apache.linkis.scheduler.queue.{ConsumerManager, GroupFactory}
import org.springframework.context.annotation.{Bean, Configuration, Primary}


@Configuration
class VisualisSpringConfiguration {

  @Primary
  @Bean
  def entranceInterceptors: Array[EntranceInterceptor] = Array[EntranceInterceptor](new VisualisCSEntranceInterceptor, new ShellDangerousGrammerInterceptor, new PythonCodeCheckInterceptor, new DBInfoCompleteInterceptor, new SparkCodeCheckInterceptor, new SQLCodeCheckInterceptor, new VarSubstitutionInterceptor, new LogPathCreateInterceptor, new StorePathEntranceInterceptor, new ScalaCodeInterceptor, new SQLLimitEntranceInterceptor, new CommentInterceptor, new PythonCodeCheckInterceptor)

  @Primary
  @Bean
  def generateConsumerManager(persistenceManager: PersistenceManager) = new ReadCacheConsumerManager(ENTRANCE_SCHEDULER_MAX_PARALLELISM_USERS.getValue, persistenceManager)

  @Bean
  def generateSchedulerContext(groupFactory: GroupFactory, executorManager: ExecutorManager, consumerManager: ConsumerManager) = new EntranceSchedulerContext(groupFactory, consumerManager, executorManager)
}
