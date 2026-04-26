plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    
    // ⬇️ ضيف السطر ده هنا لتفعيل الكراش ليتكس في التطبيق
    id("com.google.firebase.crashlytics") 
    
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.art_by_hager_ismail"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ تفعيل الـ Desugaring لاستخدام ميزات Java الحديثة
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.art_by_hager_ismail"
        
        // ✅ رفع الـ minSdk لـ 21 لضمان عمل مكتبة الإشعارات والـ Desugaring
        minSdk = flutter.minSdkVersion // الأفضل تخليها 21 صراحةً عشان الكراش ليتكس والـ Desugaring
        targetSdk = flutter.targetSdkVersion
        
        // ✅ تفعيل MultiDex لدعم عدد كبير من المكتبات
        multiDexEnabled = true
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // 💡 نصيحة احترافية: هنا ممكن تفعل الـ mapping عشان التقارير تظهر واضحة
            // firebaseCrashlytics { nativeSymbolUploadEnabled = true }
        }
    }
}

flutter {
    source = "../.."
}

// ✅ إضافة المكتبة المطلوبة لعمل الـ Desugaring
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
