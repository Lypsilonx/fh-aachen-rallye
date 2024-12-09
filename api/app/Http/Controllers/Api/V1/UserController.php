<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\UpdateUserRequest;
use App\Models\User;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\UserResource;
use App\Http\Resources\V1\UserCollection;
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

            foreach ($challengeStates as $challenge_id => $step) {
                $user->challengeStates()->updateOrCreate(
                    [
                        'challenge_id' => $challenge_id,
                        'user_id' => $user->id
                    ],
                    [
                        'step' => $step
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
        //
    }
}
