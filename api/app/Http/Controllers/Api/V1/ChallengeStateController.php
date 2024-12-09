<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreChallengeStateRequest;
use App\Http\Requests\V1\UpdateChallengeStateRequest;
use App\Models\ChallengeState;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ChallengeStateResource;
use App\Http\Resources\V1\ChallengeStateCollection;
use Illuminate\Http\Request;

class ChallengeStateController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return new ChallengeStateCollection(ChallengeState::paginate());
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreChallengeStateRequest $request)
    {
        return new ChallengeStateResource(ChallengeState::create($request->all()));
    }

    /**
     * Display the specified resource.
     */
    public function show(ChallengeState $challengeState)
    {
        if (!auth()->user()->tokenCan('read:challengeStates')) {
            abort(403, 'Unauthorized action.');
        }

        return new ChallengeStateResource($challengeState);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(ChallengeState $challengeState)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateChallengeStateRequest $request, ChallengeState $challengeState)
    {
        $challengeState->update($request->all());

        return new ChallengeStateResource($challengeState);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ChallengeState $challengeState)
    {
        if (!auth()->user()->tokenCan('delete:challengeStates')) {
            abort(403, 'Unauthorized action.');
        }

        $challengeState->delete();

        return response()->json([
            'status' => true,
            'message' => 'Challenge state deleted successfully'
        ]);
    }
}
