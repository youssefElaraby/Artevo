// 1. تعريف الـ Plugins المطلوبة للمشروع
plugins {
    // شيلنا الإصدارات هنا عشان نستخدم الإصدارات المتوافقة مع مشروعك (8.11.1)
    id("com.android.application") apply false
    id("kotlin-android") apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
    
    // ⬇️ إضافة Plugin الفايربيز و الـ Crashlytics بإصدارات مستقرة
    id("com.google.gms.google-services") version "4.3.15" apply false
    id("com.google.firebase.crashlytics") version "2.9.9" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}