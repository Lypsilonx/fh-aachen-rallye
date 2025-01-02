<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\UpdateUserRequest;
use App\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\UserResource;
use App\Http\Resources\V1\UserCollection;
use App\Models\Challenge;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $includeChallengeStates = $request->query('includeChallengeStates', false);

        if ($includeChallengeStates) {
            return new UserCollection(User::with('challengeStates')->paginate());
        }

        return new UserCollection(User::paginate());
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        if (!auth()->user()->tokenCan('read:users')) {
            abort(403, 'Unauthorized action.');
        }

        $includeChallengeStates = request()->query('includeChallengeStates', false);

        if ($includeChallengeStates) {
            return new UserResource($user->loadMissing('challengeStates'));
        }

        return new UserResource($user);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(User $user)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateUserRequest $request, User $user)
    {
        $user->update($request->all());

        if ($request->has('challengeStates')) {
            $challengeStates = $request->input('challengeStates');

            if (is_string($challengeStates)) {
                $challengeStates = json_decode($challengeStates, true);
            }

            foreach ($challengeStates as $challenge_id => $challengeState) {
                $step = $challengeState['step'];

                if ($step === -2) {
                    $previousStep = $user->challengeStates()->where('challenge_id', $challenge_id)->where('user_id', $user->id)->first();
                    if (!$step) {
                        continue;
                    }

                    if ($previousStep->step !== -2) {
                        GameController::completeChallenge($user, $challenge_id);
                    }
                }

                $user->challengeStates()->updateOrCreate(
                    [
                        'challenge_id' => $challenge_id,
                        'user_id' => $user->id
                    ],
                    [
                        'step' => $step,
                        'shuffleSource' => $challengeState['shuffleSource'],
                        'shuffleTargets' => $challengeState['shuffleTargets']
                    ]
                );
            }
        }

        $user->load('challengeStates');

        return new UserResource($user);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user)
    {
        if (!auth()->user()->tokenCan('delete:users')) {
            abort(403, 'Unauthorized action.');
        }

        $user->delete();

        return response()->json([
            'status' => true,
            'message' => 'User deleted successfully'
        ]);
    }
}
