<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use App\Models\Challenge;
use App\Models\ChallengeState;
use Hash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class GameController extends Controller
{
    public function unlockRequest(Request $request)
    {
        try {
            $validatedUser = Validator::make(
                $request->all(),
                [
                    'lock_id' => 'required',
                ],
            );

            if ($validatedUser->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation failed',
                    'errors' => $validatedUser->errors()
                ], 401);
            }

            $user = User::find(auth()->id());

            if (!$user) {
                return response()->json([
                    'status' => false,
                    'message' => 'User not found',
                ], 404);
            }

            $unlocked_challenges = GameController::unlock($user, $request->input('lock_id'));

            return response()->json([
                'status' => true,
                'unlocked_challenges' => $unlocked_challenges[0],
                'total_challenges' => $unlocked_challenges[1],
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => $e->getMessage()
            ], 500);
        }

    }

    public static function completeChallenge(User $user, string $challenge_id)
    {
        $challenge = Challenge::where('challenge_id', $challenge_id)->first();
        $user->points += $challenge->points;
        $user->save();

        if ($challenge->unlock_id) {
            GameController::unlock($user, $challenge->unlock_id);
        }
    }

    public static function unlock(User $user, string $lock_id): array
    {
        $challenges = Challenge::where('lock_id', $lock_id)->get();
        $challenges = $challenges->unique('challenge_id');

        if ($challenges->isEmpty()) {
            return [0, 0];
        }

        $unlocked_challenges = 0;
        foreach ($challenges as $challenge) {
            $challengeState = ChallengeState::where('user_id', $user->id)
                ->where('challenge_id', $challenge->challenge_id)
                ->first();

            if ($challengeState) {
                continue;
            }

            $challengeState = ChallengeState::create([
                'user_id' => $user->id,
                'challenge_id' => $challenge->challenge_id,
                'step' => -1,
            ]);
            $unlocked_challenges++;
        }

        return [$unlocked_challenges, $challenges->count()];
    }
}
