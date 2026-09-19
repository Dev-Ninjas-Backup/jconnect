allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Stripe's push-provisioning module (NFC card provisioning) requires a special
    // Google agreement and its dependency 'play-services-tapandpay' is not available
    // in any public Maven repository. Exclude it to allow the build to succeed.
    configurations.configureEach {
        exclude(group = "com.stripe", module = "stripe-android-issuing-push-provisioning")
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
