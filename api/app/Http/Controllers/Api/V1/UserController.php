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
        $includeSteps = $request->query('includeSteps', false);

        if ($includeSteps) {
            return new UserCollection(User::with('steps')->paginate());
        }

        return new UserCollection(User::paginate());
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        $includeSteps = request()->query('includeSteps', false);

        if ($includeSteps) {
            return new UserResource($user->loadMissing('steps'));
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
