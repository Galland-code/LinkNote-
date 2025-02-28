buildscript {
    repositories {
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/gradle-plugin")
        }
        google()  // 保留 Google 官方仓库
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")  // 确保版本与错误中的插件版本一致
    }
}
allprojects {
    repositories {
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        google()  // 保留 Google 官方仓库
    }
}
//allprojects {
//    repositories {
//
//        google()
//        mavenCentral()
//    }
//}


val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
