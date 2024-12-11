<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Challenge;
use App\Http\Controllers\Api\V1\ChallengeController;
use Illuminate\Support\Facades\File;

class ChallengeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // load challenges from resources/data/challenges/<challenge>.json
        $files = File::files(base_path('resources/data/challenges'));

        foreach ($files as $file) {
            $challengeJson = json_decode(File::get($file), true);

            $challenge = Challenge::create([
                'id' => $challengeJson['id'],
                'title' => $challengeJson['title'],
                'difficulty' => $challengeJson['difficulty'],
                'points' => $challengeJson['points'],
                'category' => $challengeJson['category'],
                'descriptionStart' => $challengeJson['descriptionStart'],
                'descriptionEnd' => $challengeJson['descriptionEnd'],
                'image' => $challengeJson['image'],
            ]);

            ChallengeController::storeSteps($challenge, $challengeJson['steps']);
        }
    }
}
