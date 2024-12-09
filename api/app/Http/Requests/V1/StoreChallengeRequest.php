<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreChallengeRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'id' => ['required', 'string', 'max:16'],
            'title' => ['required', 'string', 'max:255'],
            'difficulty' => ['required', 'integer', 'min:0', 'max:5'],
            'points' => ['required', 'integer', 'min:0'],
            'category' => ['required', 'string', 'max:255'],
            'descriptionStart' => ['required', 'string'],
            'descriptionEnd' => ['required', 'string'],
            'image' => ['string', 'nullable'],
        ];
    }
}
