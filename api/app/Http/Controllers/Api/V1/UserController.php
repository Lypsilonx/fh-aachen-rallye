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
