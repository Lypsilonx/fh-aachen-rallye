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
        // load challenges from resources/data/challenges/(<subfolders>/)?<challenge>.json
        $files = File::allFiles(base_path('resources/data/challenges'));

        foreach ($files as $file) {
            $challengeJson = json_decode(File::get($file), true);

            $tags = $challengeJson['tags'] ?? null;

            $subfolder = $file->getRelativePath();
            if ($subfolder !== "") {
                if ($tags === null) {
                    $tags = $subfolder;
                } else {
                    $tags .= ",$subfolder";
                }
            }

            $challenge = Challenge::updateOrCreate(
                [
                    'challenge_id' => $challengeJson['challenge_id'],
                    'language' => $challengeJson['language'],
                ],
                [
                    'title' => $challengeJson['title'],
                    'difficulty' => $challengeJson['difficulty'],
                    'tags' => $tags,
                    'duration' => $challengeJson['duration'],
                    'lock_id' => $challengeJson['lock_id'] ?? null,
                    'unlock_id' => $challengeJson['unlock_id'] ?? null,
                    'points' => $challengeJson['points'],
                    'category' => $challengeJson['category'],
                    'descriptionStart' => $challengeJson['descriptionStart'],
                    'descriptionEnd' => $challengeJson['descriptionEnd'],
                    'image' => $challengeJson['image'] ?? null,
                ]
            );

            ChallengeController::storeSteps($challenge, $challengeJson['steps']);
        }
    }
}
