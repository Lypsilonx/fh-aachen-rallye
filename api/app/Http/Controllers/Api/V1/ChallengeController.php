<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreChallengeRequest;
use App\Http\Requests\V1\UpdateChallengeRequest;
use App\Models\Challenge;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ChallengeResource;
use App\Http\Resources\V1\ChallengeCollection;
use Request;

class ChallengeController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $includeSteps = $request->query('includeSteps', false);

        if ($includeSteps) {
            return new ChallengeCollection(Challenge::with('steps')->paginate());
        }

        return new ChallengeCollection(Challenge::paginate());
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
    public function store(StoreChallengeRequest $request)
    {
        return new ChallengeResource(Challenge::create($request->all()));
    }

    /**
     * Display the specified resource.
     */
    public function show(Challenge $challenge)
    {
        $includeSteps = request()->query('includeSteps', false);

        if ($includeSteps) {
            return new ChallengeResource($challenge->loadMissing('steps'));
        }

        return new ChallengeResource($challenge);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Challenge $challenge)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateChallengeRequest $request, Challenge $challenge)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Challenge $challenge)
    {
        //
    }
}
