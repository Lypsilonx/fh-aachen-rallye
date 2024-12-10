<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('translations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('key');
            $table->string('language');
            $table->text('value');
            $table->timestamps();
        });

        //put some initial data

        $initialTranslations = [
            ['key' => 'LOGIN', 'en' => 'Login', 'de' => 'Anmelden'],
            ['key' => 'REGISTER', 'en' => 'Register', 'de' => 'Registrieren'],
            ['key' => 'LOGOUT', 'en' => 'Logout', 'de' => 'Abmelden'],
            ['key' => 'USERNAME', 'en' => 'Username', 'de' => 'Benutzername'],
            ['key' => 'PASSWORD', 'en' => 'Password', 'de' => 'Passwort'],
            ['key' => 'ALREADY_REGISTERED', 'en' => 'Already registered? Log in!', 'de' => 'Bereits registriert? Melde dich an!'],
            ['key' => 'NOT_REGISTERED', 'en' => 'Not registered? Register!', 'de' => 'Noch nicht registriert? Registriere dich!'],
            ['key' => 'ACCOUNT', 'en' => 'Account', 'de' => 'Benutzerkonto'],
            ['key' => 'SETTINGS', 'en' => 'Settings', 'de' => 'Einstellungen'],
            ['key' => 'SAVE', 'en' => 'Save', 'de' => 'Speichern'],
            ['key' => 'CANCEL', 'en' => 'Cancel', 'de' => 'Abbrechen'],
            ['key' => 'EDIT', 'en' => 'Edit', 'de' => 'Bearbeiten'],
            ['key' => 'DELETE', 'en' => 'Delete', 'de' => 'Löschen'],
            ['key' => 'CHALLENGES', 'en' => 'Challenges', 'de' => 'Aufgaben'],
        ];

        foreach ($initialTranslations as $initialTranslation) {
            $id = \Ramsey\Uuid\Uuid::uuid4();
            $key = $initialTranslation['key'];
            $value = $initialTranslation['en'];
            $language = 'english';

            DB::table('translations')->insert([
                'id' => \Ramsey\Uuid\Uuid::uuid4(),
                'key' => $key,
                'language' => $language,
                'value' => $value,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            $value = $initialTranslation['de'];
            $language = 'german';

            DB::table('translations')->insert([
                'id' => \Ramsey\Uuid\Uuid::uuid4(),
                'key' => $key,
                'language' => $language,
                'value' => $value,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('translations');
    }
};
