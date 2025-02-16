<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Translation;

class TranslationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //put some initial data from resources/data/translations.json
        $initialTranslations = json_decode(file_get_contents(base_path('resources/data/translations.json')), true);

        foreach ($initialTranslations as $key => $initialTranslation) {
            Translation::updateOrCreate([
                'key' => $key,
                'language' => 'en',
            ], [
                'value' => $initialTranslation['en'],
            ]);

            Translation::updateOrCreate([
                'key' => $key,
                'language' => 'de',
            ], [
                'value' => $initialTranslation['de'],
            ]);
        }
    }
}