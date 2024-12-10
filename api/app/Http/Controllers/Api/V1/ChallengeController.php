<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreChallengeRequest;
use App\Http\Requests\V1\UpdateChallengeRequest;
use App\Models\Challenge;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ChallengeResource;
use App\Http\Resources\V1\ChallengeCollection;
use Illuminate\Http\Request;

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
        $challenge = Challenge::create($request->all());

        if ($request->has('steps')) {
            $steps = $request->input('steps');

            if (is_string($steps)) {
                $steps = json_decode($steps, true);
            }

            foreach ($steps as $step) {
                $values = [
                    'type' => $step['type'],
                    'text' => $step['text'],
                    'next' => $step['next'],
                    'isLast' => $step['isLast'],
                ];

                if ($step['type'] === 'options') {
                    $values['options'] = $step['options'];
                }

                if ($step['type'] === 'stringInput') {
                    $values['correctAnswer'] = $step['correctAnswer'];
                    $values['indexOnIncorrect'] = $step['indexOnIncorrect'];
                }

                $challenge->steps()->updateOrCreate(
                    [
                        'challenge_id' => $challenge->id,
                        'index' => $step['index'],
                    ],
                    $values
                );
            }
        }

        $challenge->load('steps');

        return new ChallengeResource($challenge);
    }

    /**
     * Display the specified resource.
     */
    public function show(Challenge $challenge)
    {
        if (!auth()->user()->tokenCan('read:challenges')) {
            abort(403, 'Unauthorized action.');
        }

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
        $challenge->update($request->all());

        if ($request->has('steps')) {
            $steps = $request->input('steps');

            if (is_string($steps)) {
                $steps = json_decode($steps, true);
            }

            foreach ($steps as $step) {
                $values = [
                    'type' => $step['type'],
                    'text' => $step['text'],
                    'next' => $step['next'],
                    'isLast' => $step['isLast'],
                ];

                if ($step['type'] === 'options') {
                    $values['options'] = $step['options'];
                }

                if ($step['type'] === 'stringInput') {
                    $values['correctAnswer'] = $step['correctAnswer'];
                    $values['indexOnIncorrect'] = $step['indexOnIncorrect'];
                }

                $challenge->steps()->updateOrCreate(
                    [
                        'challenge_id' => $challenge->id,
                        'index' => $step['index'],
                    ],
                    $values
                );
            }
        }

        $challenge->load('steps');

        return new ChallengeResource($challenge);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Challenge $challenge)
    {
        if (!auth()->user()->tokenCan('delete:challenges')) {
            abort(403, 'Unauthorized action.');
        }

        $challenge->delete();

        return response()->json([
            'status' => true,
            'message' => 'Challenge deleted successfully'
        ]);
    }
}
