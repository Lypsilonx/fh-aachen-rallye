<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use App\Models\Challenge;
use App\Models\ChallengeState;
use Hash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
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

            unlockForUser($user, $request->input('lock_id'));

            return response()->json([
                'status' => true,
                'message' => 'Challenges unlocked',
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
        $challenge = Challenge::find($challenge_id);
        $user->points += $challenge->points;
        $user->save();

        GameController::unlock($user, $challenge->unlock_id);
    }

    public static function unlock(User $user, string $lock_id)
    {
        $challenges = Challenge::where('lock_id', $lock_id)->get();

        foreach ($challenges as $challenge) {
            // add challenge_state with step=-1
            $challengeState = ChallengeState::create([
                'user_id' => $user->id,
                'challenge_id' => $challenge->id,
                'step' => -1,
            ]);
        }
    }
}
