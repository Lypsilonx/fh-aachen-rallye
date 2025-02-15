<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreChallengeStepRequest;
use App\Http\Requests\V1\UpdateChallengeStepRequest;
use App\Models\ChallengeStep;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ChallengeStepResource;
use App\Http\Resources\V1\ChallengeStepCollection;
use Illuminate\Http\Request;

class ChallengeStepController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return new ChallengeStepCollection(ChallengeStep::paginate());
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
    public function store(StoreChallengeStepRequest $request)
    {
        return new ChallengeStepResource(ChallengeStep::create($request->all()));
    }

    /**
     * Display the specified resource.
     */
    public function show(ChallengeStep $challengeStep)
    {
        if (!auth()->user()->tokenCan('read:challengeSteps')) {
            abort(403, 'Unauthorized action.');
        }

        return new ChallengeStepResource($challengeStep);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(ChallengeStep $challengeStep)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateChallengeStepRequest $request, ChallengeStep $challengeStep)
    {
        $challengeStep->update($request->all());

        return new ChallengeStepResource($challengeStep);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ChallengeStep $challengeStep)
    {
        if (!auth()->user()->tokenCan('delete:challengeSteps')) {
            abort(403, 'Unauthorized action.');
        }

        $challengeStep->delete();

        return response()->json([
            'status' => true,
            'message' => 'Challenge step deleted successfully'
        ]);
    }
}
