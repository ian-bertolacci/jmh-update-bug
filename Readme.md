# Demonstration of issue
When developing, I sometimes make lots of changes until I like what I have.

In JMH, using the jmh-gradle-plugin (https://github.com/melix/jmh-gradle-plugin), this causes an issue, but only when using the gradle daemon.

To be specific, if I run `gradle clean build jmh`, then later change a class that JMH uses as a benchmark source, then run `gradle clean build jmh` again, this causes a java.lang.IncompatibleClassChangeError exception to be thrown

# Quick-Start:
```bash
./run.sh
```

Expected (buggy) output:
```
===========================================================
-- project_base_working
-----------------------------------------------------------
Success
Success
===========================================================
===========================================================
-- project_updated_before_gradle_invocation_working
-----------------------------------------------------------
Success
Success
===========================================================
===========================================================
-- project_updated_after_gradle_invocation_broken
-----------------------------------------------------------
Success
Fail (expected)
===========================================================
===========================================================
-- project_updated_after_gradle_no_daemon_invocation_working
-----------------------------------------------------------
Success
Success
===========================================================
```


Desired (non-buggy) output:

```
===========================================================
-- project_base_working
-----------------------------------------------------------
Success
Success
===========================================================
===========================================================
-- project_updated_before_gradle_invocation_working
-----------------------------------------------------------
Success
Success
===========================================================
===========================================================
-- project_updated_after_gradle_invocation_broken
-----------------------------------------------------------
Success
Success
===========================================================
===========================================================
-- project_updated_after_gradle_no_daemon_invocation_working
-----------------------------------------------------------
Success
Success
===========================================================
```


# Description of Example
CLEAN_project is our project source and will be copied from multiple times, so do not run anything inside of CLEAN_project as it will mess up the demo.

In the project, there is a benchmark definition source file `project/src/jmh/MyClassBenchmark.java`
It has an internal factory class, `FactoryA`.

This is fine, but lets say I then add a different factory, `FactoryB`.
The updated file is shown in `ROOT/MyClassBenchmark.java.update`
This is perfectly valid Java code and is perfectly acceptable to JMH (ignoring developer taste or best practices).

If working from a *clean* project, making the changes (in this case, overwriting/patching the MyClassBenchmark.java file with the MyClassBenchmark.java.update file), and *then* running `gradle clean build jmh` is perfectly fine, and the project will build and the benchmark will run successfully.

In contrast, if working from a *clean* project, *first* running `gradle clean build jmh`, *then* making the changes, and *finally* running `gradle clean build jmh` again, it will throw the java.lang.IncompatibleClassChangeError.

The full output for this case (which can be found in `outputs/project_updated_after_gradle_invocation_broken.2.out`):
```
> Task :clean
> Task :compileJava
> Task :processResources NO-SOURCE
> Task :classes
> Task :jar
> Task :assemble
> Task :compileTestJava NO-SOURCE
> Task :processTestResources NO-SOURCE
> Task :testClasses UP-TO-DATE
> Task :test NO-SOURCE
> Task :check UP-TO-DATE
> Task :build
> Task :compileJmhJava
> Task :processJmhResources NO-SOURCE
> Task :jmhClasses

> Task :jmhRunBytecodeGenerator FAILED
Processing 4 classes from /home/ian/Projects/TestCode/jmh-gradle-plugin-change-bug/project_updated_after_gradle_invocation_broken/build/classes/java/jmh with "reflection" generator
Writing out Java source to /home/ian/Projects/TestCode/jmh-gradle-plugin-change-bug/project_updated_after_gradle_invocation_broken/build/jmh-generated-sources and resources to /home/ian/Projects/TestCode/jmh-gradle-plugin-change-bug/project_updated_after_gradle_invocation_broken/build/jmh-generated-resources

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':jmhRunBytecodeGenerator'.
> A failure occurred while executing me.champeau.gradle.JmhBytecodeGeneratorRunnable
   > Generation of JMH bytecode failed with 1 errors:
       - Annotation generator had thrown the exception.
     java.lang.IncompatibleClassChangeError: com.cool.library.benchmarks.MyClassBenchmark and com.cool.library.benchmarks.MyClassBenchmark$FactoryB disagree on InnerClasses attribute
       at java.base/java.lang.Class.getDeclaringClass0(Native Method)
       at java.base/java.lang.Class.getEnclosingClass(Class.java:1517)
       at java.base/java.lang.Class.getCanonicalName0(Class.java:1625)
       at java.base/java.lang.Class.getCanonicalName(Class.java:1610)
       at org.openjdk.jmh.generators.reflection.RFClassInfo.getQualifiedName(RFClassInfo.java:67)
       at org.openjdk.jmh.generators.core.BenchmarkGenerator.buildAnnotatedSet(BenchmarkGenerator.java:206)
       at org.openjdk.jmh.generators.core.BenchmarkGenerator.generate(BenchmarkGenerator.java:75)
       at me.champeau.gradle.JmhBytecodeGeneratorRunnable.run(JmhBytecodeGeneratorRunnable.java:126)
       at org.gradle.workers.internal.AdapterWorkAction.execute(AdapterWorkAction.java:57)
       at org.gradle.workers.internal.DefaultWorkerServer.execute(DefaultWorkerServer.java:63)
       at org.gradle.workers.internal.AbstractClassLoaderWorker$1.create(AbstractClassLoaderWorker.java:49)
       at org.gradle.workers.internal.AbstractClassLoaderWorker$1.create(AbstractClassLoaderWorker.java:43)
       at org.gradle.internal.classloader.ClassLoaderUtils.executeInClassloader(ClassLoaderUtils.java:97)
       at org.gradle.workers.internal.AbstractClassLoaderWorker.executeInClassLoader(AbstractClassLoaderWorker.java:43)
       at org.gradle.workers.internal.IsolatedClassloaderWorker.run(IsolatedClassloaderWorker.java:49)
       at org.gradle.workers.internal.IsolatedClassloaderWorker.run(IsolatedClassloaderWorker.java:30)
       at org.gradle.workers.internal.WorkerDaemonServer.run(WorkerDaemonServer.java:85)
       at org.gradle.workers.internal.WorkerDaemonServer.run(WorkerDaemonServer.java:55)
       at org.gradle.process.internal.worker.request.WorkerAction$1.call(WorkerAction.java:138)
       at org.gradle.process.internal.worker.child.WorkerLogEventListener.withWorkerLoggingProtocol(WorkerLogEventListener.java:41)
       at org.gradle.process.internal.worker.request.WorkerAction.run(WorkerAction.java:135)
       at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
       at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
       at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
       at java.base/java.lang.reflect.Method.invoke(Method.java:566)
       at org.gradle.internal.dispatch.ReflectionDispatch.dispatch(ReflectionDispatch.java:36)
       at org.gradle.internal.dispatch.ReflectionDispatch.dispatch(ReflectionDispatch.java:24)
       at org.gradle.internal.remote.internal.hub.MessageHubBackedObjectConnection$DispatchWrapper.dispatch(MessageHubBackedObjectConnection.java:182)
       at org.gradle.internal.remote.internal.hub.MessageHubBackedObjectConnection$DispatchWrapper.dispatch(MessageHubBackedObjectConnection.java:164)
       at org.gradle.internal.remote.internal.hub.MessageHub$Handler.run(MessageHub.java:414)
       at org.gradle.internal.concurrent.ExecutorPolicy$CatchAndRecordFailures.onExecute(ExecutorPolicy.java:64)
       at org.gradle.internal.concurrent.ManagedExecutorImpl$1.run(ManagedExecutorImpl.java:48)
       at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
       at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
       at org.gradle.internal.concurrent.ThreadFactoryImpl$ManagedThreadRunnable.run(ThreadFactoryImpl.java:56)
       at java.base/java.lang.Thread.run(Thread.java:834)
```


This can be worked around by running gradle with `--no-daemon`, or by restarting *all* gradle daemons.
