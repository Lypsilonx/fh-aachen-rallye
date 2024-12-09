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
            'id' => ['required', 'string', 'max:16'],
            'challenge_id' => ['required', 'string', 'max:16', 'exists:challenges,id'],
            'type' => ['required', 'string', 'max:255'],
            'text' => ['required', 'string'],
            'next' => ['integer', 'nullable'],
            'isLast' => ['required', 'boolean'],
        ];

        if ($this->input('type') === 'options') {
            $rules['options'] = ['required', 'string'];
        }

        if ($this->input('type') === 'stringInput') {
            $rules['correctAnswer'] = ['required', 'string'];
            $rules['indexOnIncorrect'] = ['required', 'integer'];
        }

        return $rules;
    }
}
