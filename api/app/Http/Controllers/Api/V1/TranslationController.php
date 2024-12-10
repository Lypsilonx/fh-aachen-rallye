<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreTranslationRequest;
use App\Http\Requests\V1\UpdateTranslationRequest;
use App\Models\Translation;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\TranslationResource;
use App\Http\Resources\V1\TranslationCollection;
use Illuminate\Http\Request;

class TranslationController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        return new TranslationCollection(Translation::paginate());
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
    public function store(StoreTranslationRequest $request)
    {
        $translation = Translation::create($request->all());

        return new TranslationResource($translation);
    }

    /**
     * Display the specified resource.
     */
    public function show(Translation $translation)
    {
        return new TranslationResource($translation);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Translation $translation)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateTranslationRequest $request, Translation $translation)
    {
        $translation->update($request->all());

        return new TranslationResource($translation);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Translation $translation)
    {
        if (!auth()->user()->tokenCan('delete:translations')) {
            abort(403, 'Unauthorized action.');
        }

        $translation->delete();

        return response()->json([
            'status' => true,
            'message' => 'Translation deleted successfully'
        ]);
    }
}
