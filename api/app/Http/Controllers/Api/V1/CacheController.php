<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use App\Models\Challenge;
use App\Models\ChallengeStep;
use App\Models\ChallengeState;
use Cache;
use DateTime;
use DateTimeZone;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;

class CacheController extends Controller
{
    public function cachePollRequest(Request $request)
    {
        try {
            $poll_list = $request->poll_list;
            $update_list = [];

            foreach ($poll_list as $poll) {
                $type = $poll['type'];
                $id = $poll['id'];
                $lastUpdated = $poll['lastUpdate'] / 1000;

                $typeClass = "\\App\\Models\\" . ucfirst($type);

                if (!class_exists($typeClass)) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Type ' . $type . ' not found',
                    ], 404);
                }

                if ($id == 'all') {
                    // add to update_list if any object was added since lastUpdated
                    $objects = $typeClass::all();
                    foreach ($objects as $object) {
                        if (CacheController::getUpdatedAt($typeClass, $object)->getTimestamp() > $lastUpdated) {
                            $update_list[] = "$type:*";
                            break;
                        }
                    }
                } else if ($id == '*') {
                    // add to update_list if any object was updated since lastUpdated
                    $objects = $typeClass::all();
                    foreach ($objects as $object) {
                        if (CacheController::getUpdatedAt($typeClass, $object)->getTimestamp() > $lastUpdated) {
                            $update_list[] = "$type:" . $object->id;
                        }
                    }
                } else {
                    $object = $typeClass::find($id);
                    if (CacheController::getUpdatedAt($typeClass, $object)->getTimestamp() > $lastUpdated) {
                        $update_list[] = "$type:" . $id;
                    }
                }
            }

            return response()->json([
                'status' => true,
                'update_list' => $update_list
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    private static function getUpdatedAt($typeClass, $object): DateTime
    {
        if ($typeClass == "\\App\\Models\\Challenge") {
            // check ChallengeSteps too
            $challengeSteps = ChallengeStep::where('challenge_id', $object->id)->get();
            $updatedAt = $object->updated_at;
            foreach ($challengeSteps as $challengeStep) {
                if ($challengeStep->updated_at > $updatedAt) {
                    $updatedAt = $challengeStep->updated_at;
                }
            }

            return new DateTime($updatedAt, new DateTimeZone('UTC'));
        } else if ($typeClass == "\\App\\Models\\User") {
            // check ChallengeStates too
            $challengeStates = ChallengeState::where('user_id', $object->id)->get();
            $updatedAt = $object->updated_at;
            foreach ($challengeStates as $challengeState) {
                if ($challengeState->updated_at > $updatedAt) {
                    $updatedAt = $challengeState->updated_at;
                }
            }

            return new DateTime($updatedAt, new DateTimeZone('UTC'));
        } else {
            return new DateTime($object->updated_at, new DateTimeZone('UTC'));
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
