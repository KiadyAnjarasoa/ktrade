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

// 👈 ANTSOINA SY ONARENA AMIN'NY SDK 36 IREO SUBPROJECTS REHETRA (toy ny file_picker)
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension> {
            compileSdk = 36
        }
    }
    pluginManager.withPlugin("com.android.application") {
        extensions.configure<com.android.build.api.dsl.ApplicationExtension> {
            compileSdk = 36
        }
    }
}