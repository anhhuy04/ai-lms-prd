import com.android.build.gradle.LibraryExtension
import java.io.FileInputStream
import java.util.Properties

val localProps = Properties()
val localPropsFile = rootProject.file("local.properties")
if (localPropsFile.exists()) {
    FileInputStream(localPropsFile).use { localProps.load(it) }
}
val flutterSdk: String? = localProps.getProperty("flutter.sdk")

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (name == "uni_links") {
        afterEvaluate {
            extensions.findByType(LibraryExtension::class.java)?.apply {
                namespace = "name.avioli.unilinks"
                compileSdk = 34
            }
            if (flutterSdk != null) {
                dependencies {
                    add(
                        "compileOnly",
                        files("$flutterSdk/bin/cache/artifacts/engine/android-arm/flutter.jar"),
                    )
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
