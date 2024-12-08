<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreChallengeStepRequest extends FormRequest
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
        $rules = [
            'challenge_id' => ['required', 'integer', 'exists:challenges,id'],
            'type' => ['required', 'string', 'max:255'],
            'text' => ['required', 'string'],
            'next' => ['integer', 'nullable'],
            'isLast' => ['required', 'boolean'],
        ];

        if ($this->input('type') === 'options') {
            array_push($rules, [
                'options' => ['string'],
            ]);
        }

        if ($this->input('type') === 'stringInput') {
            array_push($rules, [
                'correctAnswer' => ['string'],
                'indexOnIncorrect' => ['string'],
            ]);
        }

        return $rules;
    }
}
